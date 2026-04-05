import XCTest
@testable import LAYTEKS

final class KaTeXEscapeTests: XCTestCase {

    func test_escapeForJS_backslash() {
        let input = "\\frac{1}{2}"
        let result = input.escapedForJS()
        XCTAssertEqual(result, "\\\\frac{1}{2}")
    }

    func test_escapeForJS_singleQuote() {
        let input = "it's"
        let result = input.escapedForJS()
        XCTAssertEqual(result, "it\\'s")
    }

    func test_escapeForJS_newline() {
        let input = "line1\nline2"
        let result = input.escapedForJS()
        XCTAssertEqual(result, "line1\\nline2")
    }

    func test_escapeForJS_complex() {
        let input = "\\int_{-\\infty}^{\\infty} e^{-x^2} dx = \\sqrt{\\pi}"
        let result = input.escapedForJS()
        XCTAssertTrue(result.contains("\\\\int"))
        XCTAssertFalse(result.contains("\n"))
    }
}
