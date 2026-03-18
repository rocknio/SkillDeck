import XCTest
import Markdown
@testable import SkillDeck

final class MarkdownPreprocessorTests: XCTestCase {

    func testStripWrapperTags_allowsSwiftMarkdownToParseHeadingInside() {
        let input = """
        <EXTREMELY-IMPORTANT>
        # Title

        - Item 1
        - Item 2
        </EXTREMELY-IMPORTANT>
        """

        let sanitized = MarkdownPreprocessor.stripWrapperTags(input)
        let doc = Document(parsing: sanitized)
        let children = Array(doc.children)

        XCTAssertTrue(children.first is Heading)
        XCTAssertTrue(children.contains { $0 is UnorderedList })
    }

    func testStripWrapperTags_stripsTagsWithAttributes_andHtmlComments() {
        let input = """
        <!-- OMO_INTERNAL_INITIATOR -->
        <true_memory_context type=\"global\" worktree=\"/tmp/foo\">
        # Title

        - Item 1
        - Item 2
        </true_memory_context>
        """

        let sanitized = MarkdownPreprocessor.stripWrapperTags(input)
        let doc = Document(parsing: sanitized)
        let children = Array(doc.children)

        XCTAssertTrue(children.first is Heading)
        XCTAssertTrue(children.contains { $0 is UnorderedList })
    }
}
