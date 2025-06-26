import AppKit
import Vision

// Helpers
struct ScriptFilter: Codable {
  var items: [Item]

  struct Item: Codable {
    var uid: String?
    var match: String?

    let title: String
    var subtitle: String?
    let type: String
    let arg: String
    let icon: Icon

    struct Icon: Codable {
      let path: String
    }
  }
}

extension ScriptFilter.Item {
  mutating func ocr() {
    let imagePath = (self.icon.path as NSString).expandingTildeInPath
    let imageURL = URL(fileURLWithPath: imagePath)

    // Load image data
    guard
      let nsImage = NSImage(contentsOf: imageURL),
      let tiffData = nsImage.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let cgImage = bitmap.cgImage
    else {
      fputs("Unable to load \(imagePath)", stderr)
      return
    }

    // Perform recognition
    guard (try? VNImageRequestHandler(cgImage: cgImage).perform([request])) != nil else {
      fputs("Unable to perform OCR on \(imagePath)", stderr)
      return
    }

    // Return early if no text found
    guard let observations = request.results else { return }

    // Add text
    let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
    self.match = "\(self.match ?? "") \(recognizedStrings.joined(separator: "\n")))"
  }
}

// Prepare recognition
let request = VNRecognizeTextRequest()
request.recognitionLevel = .fast

// Read input JSON
guard let jsonInputData = CommandLine.arguments[1].data(using: .utf8) else { fatalError("Unable to convert JSON to data.") }
var sfFull = try JSONDecoder().decode(ScriptFilter.self, from: jsonInputData)

// Modify match keys of every item
sfFull.items.indices.forEach { sfFull.items[$0].ocr() }

// Output JSON
let jsonOutputData = try JSONEncoder().encode(sfFull)
print(String(data: jsonOutputData, encoding: .utf8)!)
