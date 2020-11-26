//
//  UpdateView.swift
//  Patched Sur
//
//  Created by Benjamin Sova on 11/24/20.
//

import SwiftUI
import Files

struct UpdateView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var at: Int
    @State var progress = 0
    @State var installers = []
    @State var track = ReleaseTrack.release
    @State var latestPatch = nil as PatchedVersion?
    var body: some View {
        ZStack {
            if progress == 0 {
                VStack {
                    Text("Software Update")
                        .font(.title)
                        .bold()
                    Spacer()
                }.padding(25)
            }
            switch progress {
            case 0:
                VStack {
                    Text("Checking For Updates...")
                        .font(.title2)
                        .fontWeight(.semibold)
                    ProgressView()
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding(.horizontal)
                        .onAppear {
                            DispatchQueue.global(qos: .background).async {
                                do {
                                    if let patchedVersions = try? PatchedVersions(fromURL: "https://api.github.com/repos/BenSova/Patched-Sur/releases").filter { !$0.prerelease } {
                                        if patchedVersions[0].tagName != "v\(AppInfo.version)" {
                                            latestPatch = patchedVersions[0]
                                            progress = 1
                                        }
                                    }
//                                    if let trackFile = try? File(path: "~/.patched-sur/track.txt").readAsString() {
//                                        track = ReleaseTrack(rawValue: trackFile) ?? .release
//                                    }
//                                    let allInstallers = try InstallAssistants(fromURL:  URL(string: "https://bensova.github.io/patched-sur/installers/\(track == .developer ? "Developer" : (track == .publicbeta ? "Public" : "Release")).json")!)
                                    
                                } catch {
                                    
                                }
                            }
                        }
                }
                .fixedSize()
            case 1:
                UpdateAppView(latest: latestPatch!, p: $progress)
            case -1:
                Text("Hi You! You shouldn't really be seeing this, but here you are!")
                    .onAppear {
                        progress = 0
                        at = 0
                    }
            default:
                VStack {
                    Text("Uh-oh! Something went wrong going through the software update steps.\nError 1x\(progress)")
                    Button("Go Back Home") {
                        at = 0
                    }
                }
            }
        }
        .navigationTitle("Patched Sur")
    }
}

enum ReleaseTrack: String, CustomStringConvertible {
    case release = "Release"
    case publicbeta = "Public Beta"
    case developer = "Developer"
    
    var description: String { rawValue }
}

class AppInfo {
    static let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    static let build = Int(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)!
    static let micropatcher = { () -> String in
        guard let micropatchers = try? MicropatcherRequirements(fromURL: "https://bensova.github.io/patched-sur/micropatcher.json") else {
            return "0.5.0"
        }
        let micropatcher = micropatchers.filter { $0.patcher <= Int(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)! }.last!
        return micropatcher.version
    }()
}
