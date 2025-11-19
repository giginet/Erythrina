// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let gccIncludePrefix =
  "/usr/local/playdate/gcc-arm-none-eabi-9-2019-q4-major/lib/gcc/arm-none-eabi/9.2.1"
guard let home = Context.environment["HOME"] else {
  fatalError("could not determine home directory")
}

let swiftSettingsSimulator: [SwiftSetting] = [
  .enableExperimentalFeature("Embedded"),
  .unsafeFlags([
    "-Xfrontend", "-disable-objc-interop",
    "-Xfrontend", "-disable-stack-protector",
    "-Xfrontend", "-function-sections",
    "-Xfrontend", "-gline-tables-only",
    "-Xcc", "-DTARGET_EXTENSION",
    "-Xcc", "-I", "-Xcc", "\(gccIncludePrefix)/include",
    "-Xcc", "-I", "-Xcc", "\(gccIncludePrefix)/include-fixed",
    "-Xcc", "-I", "-Xcc", "\(gccIncludePrefix)/../../../../arm-none-eabi/include",
    "-I", "\(home)/Developer/PlaydateSDK/C_API",
  ]),
]

let cSettingsSimulator: [CSetting] = [
  .unsafeFlags([
    "-DTARGET_EXTENSION",
    "-I", "\(gccIncludePrefix)/include",
    "-I", "\(gccIncludePrefix)/include-fixed",
    "-I", "\(gccIncludePrefix)/../../../../arm-none-eabi/include",
    "-I", "\(home)/Developer/PlaydateSDK/C_API",
  ])
]

let package = Package(
    name: "Erythrina",
    products: [
        .library(
            name: "Erythrina",
            targets: ["Erythrina"]
        ),
        .library(
            name: "CPlaydate",
            targets: ["CPlaydate"]
        ),
    ],
    targets: [
        .target(
            name: "Erythrina",
            swiftSettings: swiftSettingsSimulator,
        ),
        .target(
            name: "CPlaydate",
            cSettings: cSettingsSimulator,
        ),
    ]
)
