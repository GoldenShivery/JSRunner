import Foundation
import JavaScriptCore

class JSEngine {

    // Run JavaScript code with an optional input value.
    // Supports: return values, JSON, fetch (async via semaphore), console.log capture.
    static func run(code: String, input: String?) async throws -> String {

        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {

                let context = JSContext()!
                var logs: [String] = []

                // --- console.log ---
                let consoleLog: @convention(block) (JSValue) -> Void = { value in
                    logs.append(value.toString() ?? "undefined")
                }
                context.setObject(consoleLog, forKeyedSubscript: "print" as NSString)
                context.evaluateScript("""
                    var console = {
                        log: function() {
                            var args = Array.prototype.slice.call(arguments);
                            print(args.map(function(a) {
                                return typeof a === 'object' ? JSON.stringify(a) : String(a);
                            }).join(' '));
                        },
                        error: function() { console.log.apply(console, arguments); },
                        warn: function() { console.log.apply(console, arguments); }
                    };
                """)

                // --- input variable ---
                if let input = input {
                    context.setObject(input, forKeyedSubscript: "INPUT" as NSString)
                } else {
                    context.setObject(JSValue(undefinedIn: context), forKeyedSubscript: "INPUT" as NSString)
                }

                // --- fetch (synchronous wrapper using semaphore) ---
                let fetchFn: @convention(block) (String, JSValue?) -> JSValue? = { urlString, optionsVal in
                    guard let url = URL(string: urlString) else {
                        let err = JSValue(newErrorFromMessage: "Invalid URL: \(urlString)", in: context)
                        return err
                    }

                    var request = URLRequest(url: url)
                    request.timeoutInterval = 15

                    // Parse options (method, headers, body)
                    if let options = optionsVal, !options.isUndefined, !options.isNull {
                        if let method = options.objectForKeyedSubscript("method")?.toString(), !method.isEmpty {
                            request.httpMethod = method.uppercased()
                        }
                        if let headers = options.objectForKeyedSubscript("headers"),
                           !headers.isUndefined, !headers.isNull,
                           let dict = headers.toDictionary() as? [String: String] {
                            for (k, v) in dict { request.setValue(v, forHTTPHeaderField: k) }
                        }
                        if let bodyVal = options.objectForKeyedSubscript("body"),
                           !bodyVal.isUndefined, !bodyVal.isNull,
                           let bodyStr = bodyVal.toString() {
                            request.httpBody = bodyStr.data(using: .utf8)
                        }
                    }

                    let sem = DispatchSemaphore(value: 0)
                    var responseText = ""
                    var statusCode = 200

                    URLSession.shared.dataTask(with: request) { data, response, error in
                        defer { sem.signal() }
                        if let http = response as? HTTPURLResponse { statusCode = http.statusCode }
                        if let data = data { responseText = String(data: data, encoding: .utf8) ?? "" }
                    }.resume()

                    sem.wait()

                    // Return a response-like object
                    let resultScript = """
                    ({
                        ok: \(statusCode >= 200 && statusCode < 300 ? "true" : "false"),
                        status: \(statusCode),
                        _body: \(jsStringLiteral(responseText)),
                        text: function() { return this._body; },
                        json: function() { return JSON.parse(this._body); }
                    })
                    """
                    return context.evaluateScript(resultScript)
                }
                context.setObject(fetchFn, forKeyedSubscript: "fetch" as NSString)

                // --- atob / btoa ---
                let btoa: @convention(block) (String) -> String = { str in
                    Data(str.utf8).base64EncodedString()
                }
                let atob: @convention(block) (String) -> String = { str in
                    guard let data = Data(base64Encoded: str) else { return "" }
                    return String(data: data, encoding: .utf8) ?? ""
                }
                context.setObject(btoa, forKeyedSubscript: "btoa" as NSString)
                context.setObject(atob, forKeyedSubscript: "atob" as NSString)

                // --- error handler ---
                var jsError: String? = nil
                context.exceptionHandler = { _, exception in
                    jsError = exception?.toString() ?? "Unknown JS error"
                }

                // --- wrap user code so `return` works at top level ---
                let wrapped = """
                (function() {
                \(code)
                })()
                """

                let result = context.evaluateScript(wrapped)

                if let err = jsError {
                    continuation.resume(throwing: JSRunError.runtimeError(err))
                    return
                }

                // Build output: result + any console.log lines
                var output = ""

                if let result = result, !result.isUndefined, !result.isNull {
                    if result.isObject {
                        // Serialize objects/arrays to JSON
                        let json = context.evaluateScript("JSON.stringify(\(wrapped.isEmpty ? "undefined" : "(function(){ \(code) })()"))")
                        output = json?.toString() ?? result.toString() ?? ""
                    } else {
                        output = result.toString() ?? ""
                    }
                }

                // Append console.log output
                if !logs.isEmpty {
                    let logOutput = logs.joined(separator: "\n")
                    output = output.isEmpty ? logOutput : output + "\n\n[console]\n" + logOutput
                }

                if output.isEmpty { output = "undefined" }

                continuation.resume(returning: output)
            }
        }
    }

    private static func jsStringLiteral(_ str: String) -> String {
        let escaped = str
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
        return "\"\(escaped)\""
    }
}

enum JSRunError: Error, LocalizedError {
    case runtimeError(String)

    var errorDescription: String? {
        switch self {
        case .runtimeError(let msg): return "JavaScript error: \(msg)"
        }
    }
}
