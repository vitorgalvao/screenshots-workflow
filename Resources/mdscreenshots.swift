import Foundation

// Helpers
struct ScriptFilterItem: Codable {
  let uid: String
  let title: String
  let subtitle: String
  let type: String
  let icon: FileIcon
  let arg: String

  struct FileIcon: Codable {
    let path: String
  }
}

struct ScriptFilterFull: Codable {
  let skipknowledge: Bool
  let items: [ScriptFilterItem]
}

func fileSort(_ paths: [URL]) -> [URL] {
  func fileDate(_ filePath: URL) -> Date {
    guard let date = try? filePath.resourceValues(forKeys: [.creationDateKey]).creationDate
    else { return Date(timeIntervalSinceReferenceDate: 0) }
    return date
  }

  return
    paths
    .map { ($0, fileDate($0)) }  // Tuple of paths with dates
    .sorted(by: { $0.1.compare($1.1) == .orderedDescending })  // Sorted by date
    .map { $0.0 }  // Paths without dates
}

// Prepare query
let query = "kMDItemIsScreenCapture == 1"
let searchQuery = MDQueryCreate(kCFAllocatorDefault, query as CFString, nil, nil)

// Run query
MDQueryExecute(searchQuery, CFOptionFlags(kMDQuerySynchronous.rawValue))
let resultCount = MDQueryGetResultCount(searchQuery)

// No results
guard resultCount > 0 else {
  print(
    """
    {\"items\":[{\"title\":\"No Results\",
    \"subtitle\":\"Did not find any screenshots\",
    \"valid\":false}]}
    """
  )

  exit(EXIT_SUCCESS)
}

// Grab relevant screenshots
let allScreenshots: [URL] = (0..<resultCount).compactMap { resultIndex in
  let rawPointer = MDQueryGetResultAtIndex(searchQuery, resultIndex)
  let resultItem = Unmanaged<MDItem>.fromOpaque(rawPointer!).takeUnretainedValue()

  guard let resultPath = MDItemCopyAttribute(resultItem, kMDItemPath) as? String else { return nil }
  return URL(fileURLWithPath: resultPath)
}

let filteredScreenshots = {
  // Show every screenshot, exluding ~/Library
  let library = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]

  guard ProcessInfo.processInfo.environment["only_desktop"] == "1" else {
    return allScreenshots.filter({ !$0.path.hasPrefix(library.path) })
  }

  // Show every screenshot in ~/Desktop and subfolders
  let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]

  guard ProcessInfo.processInfo.environment["include_subdirectories"] == "0" else {
    return allScreenshots.filter({ $0.path.hasPrefix(desktop.path) })
  }

  // Show only screenshots at the root of ~/Desktop
  return allScreenshots.filter({ $0.deletingLastPathComponent() == desktop })
}()

// Prepare items
let sfItems = fileSort(filteredScreenshots).map {
  let resultPath = $0.path

  return ScriptFilterItem(
    uid: resultPath,
    title: URL(fileURLWithPath: resultPath).lastPathComponent,
    subtitle: (resultPath as NSString).abbreviatingWithTildeInPath,
    type: "file",
    icon: ScriptFilterItem.FileIcon(path: resultPath),
    arg: resultPath
  )
}

// Output JSON
let jsonData = try JSONEncoder().encode(ScriptFilterFull(skipknowledge: true, items: sfItems))
print(String(data: jsonData, encoding: .utf8)!)
