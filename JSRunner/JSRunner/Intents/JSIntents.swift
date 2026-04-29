import AppIntents
import Foundation

// MARK: - Main "Run JavaScript" Shortcut Action

struct RunJavaScriptIntent: AppIntent {

    static var title: LocalizedStringResource = "Run JavaScript"
    static var description = IntentDescription(
        "Run any JavaScript code. Use INPUT to access the value passed in. Return a value with `return`. Supports fetch(), JSON, console.log, btoa/atob.",
        categoryName: "JavaScript"
    )

    // The JS code to run
    @Parameter(
        title: "Code",
        description: "JavaScript code to execute. Use INPUT for the input value, return for output.",
        inputConnectionBehavior: .default
    )
    var code: String

    // Optional input to pass into the script as INPUT
    @Parameter(
        title: "Input",
        description: "Optional value passed into your script as the INPUT variable.",
        inputConnectionBehavior: .connectToPreviousIntentResult
    )
    var input: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Run JavaScript \(\.$code)") {
            \.$input
        }
    }

    func perform() async throws -> some ReturnsValue<String> & ProvidesDialog {
        let result = try await JSEngine.run(code: code, input: input)
        return .result(
            value: result,
            dialog: IntentDialog(stringLiteral: result.count > 200 ? String(result.prefix(200)) + "…" : result)
        )
    }
}

// MARK: - Bonus: "Evaluate JavaScript Expression" (quick one-liner)

struct EvaluateJSExpressionIntent: AppIntent {

    static var title: LocalizedStringResource = "Evaluate JS Expression"
    static var description = IntentDescription(
        "Quickly evaluate a single JavaScript expression and return the result. Great for math, string manipulation, and date formatting.",
        categoryName: "JavaScript"
    )

    @Parameter(
        title: "Expression",
        description: "A JavaScript expression, e.g. Math.round(3.7) or new Date().toISOString()",
        inputConnectionBehavior: .connectToPreviousIntentResult
    )
    var expression: String

    static var parameterSummary: some ParameterSummary {
        Summary("Evaluate JS \(\.$expression)")
    }

    func perform() async throws -> some ReturnsValue<String> & ProvidesDialog {
        let result = try await JSEngine.run(code: "return \(expression)", input: nil)
        return .result(
            value: result,
            dialog: IntentDialog(stringLiteral: result)
        )
    }
}

// MARK: - Bonus: "Fetch URL with JS" (API calls made easy)

struct FetchURLWithJSIntent: AppIntent {

    static var title: LocalizedStringResource = "Fetch URL with JavaScript"
    static var description = IntentDescription(
        "Fetch a URL and process the response with JavaScript. The raw response text is available as INPUT.",
        categoryName: "JavaScript"
    )

    @Parameter(title: "URL", description: "The URL to fetch")
    var url: String

    @Parameter(
        title: "Process with JS",
        description: "JavaScript to process the response. INPUT contains the response text.",
        default: "return JSON.parse(INPUT)"
    )
    var processingCode: String

    static var parameterSummary: some ParameterSummary {
        Summary("Fetch \(\.$url) and process with JS \(\.$processingCode)")
    }

    func perform() async throws -> some ReturnsValue<String> & ProvidesDialog {
        // Fetch first
        let fetchCode = "return fetch('\(url)').text();"
        let responseText = try await JSEngine.run(code: fetchCode, input: nil)

        // Then run user's processing code with response as INPUT
        let result = try await JSEngine.run(code: processingCode, input: responseText)

        return .result(
            value: result,
            dialog: IntentDialog(stringLiteral: result.count > 200 ? String(result.prefix(200)) + "…" : result)
        )
    }
}

// MARK: - App Shortcuts (shows up in Spotlight & Siri)

struct JSRunnerShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: RunJavaScriptIntent(),
            phrases: ["Run JavaScript in \(.applicationName)", "Execute JS in \(.applicationName)"],
            shortTitle: "Run JavaScript",
            systemImageName: "curlybraces"
        )
        AppShortcut(
            intent: EvaluateJSExpressionIntent(),
            phrases: ["Evaluate JS in \(.applicationName)"],
            shortTitle: "Evaluate Expression",
            systemImageName: "function"
        )
    }
}
