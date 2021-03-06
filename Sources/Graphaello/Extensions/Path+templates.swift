import Foundation
import PathKit

private let binaryPath: Path = {
  var binaryPath = Path(ProcessInfo.processInfo.arguments[0])
  do {
    while binaryPath.isSymlink {
      binaryPath = try binaryPath.symlinkDestination()
    }
  } catch {
    print("Warning: could not resolve symlink of \(binaryPath) with error \(error)")
  }
  return binaryPath
}()

extension Path {
    
    static let templates = templatePath()
    
}

private func templatePath(file: StaticString = #file) -> Path {
    #if DEBUG
    return Path(file.description).parent().parent().parent().parent() + "templates"
    #else
    return binaryPath.parent().parent() + "graphaello" + "templates"
    #endif
}
