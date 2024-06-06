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
MDQuerySetSearchScope(searchQuery, [ProcessInfo.processInfo.environment["screenshot_folder"]] as CFArray, 0)

// Run query
MDQueryExecute(searchQuery, CFOptionFlags(kMDQuerySynchronous.rawValue))
let resultCount = MDQueryGetResultCount(searchQuery)

// Grab relevant screenshots
let allScreenshots: [URL] = (0..<resultCount).compactMap { resultIndex in
  let rawPointer = MDQueryGetResultAtIndex(searchQuery, resultIndex)
  let resultItem = Unmanaged<MDItem>.fromOpaque(rawPointer!).takeUnretainedValue()

  guard let resultPath = MDItemCopyAttribute(resultItem, kMDItemPath) as? String else { return nil }

  return URL(fileURLWithPath: resultPath)
}

// Prepare items
let sfItems = fileSort(allScreenshots).map {
  let resultPath = $0.path

  return ScriptFilterItem(
    uid: resultPath,
    title: $0.lastPathComponent,
    subtitle: (resultPath as NSString).abbreviatingWithTildeInPath,
    type: "file",
    icon: ScriptFilterItem.FileIcon(path: resultPath),
    arg: resultPath
  )
}

// No results
guard sfItems.count > 0 else {
  print(
    """
    {\"items\":[{\"title\":\"No Results\",
    \"subtitle\":\"Did not find any screenshots\",
    \"valid\":false}]}
    """
  )

  exit(EXIT_SUCCESS)
}

// Output JSON
let jsonData = try JSONEncoder().encode(["items": sfItems])
print(String(data: jsonData, encoding: .utf8)!)
