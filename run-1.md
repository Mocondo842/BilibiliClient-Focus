# CI 运行 #1 — failure

| 项 | 值 |
|---|---|
| 分支 / 提交 | `derec-layout` @ `d0c3dfa57e4a60f531688d692e9a3ce3513300ff` |
| 触发 | push by Mocondo842 |
| 结果 | **failure** |
| Runner | arm64 / macOS 26.6.2 |
| Xcode | Xcode 26.6 Build version 17F113  |
| Swift | Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101) |
| Run 页面 | https://github.com/Mocondo842/BilibiliClient-Focus/actions/runs/37113320619 |

## 构建日志尾部（最后 120 行）

```

SwiftUI.Preview:2:41: note: 'Preview(_:body:)' declared here
1 | @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
2 | @freestanding(declaration) public macro Preview(_ name: String? = nil, @ViewBuilder body: @escaping @MainActor () -> any View) = #externalMacro(module: "PreviewsMacros", type: "SwiftUIView")
  |                                         `- note: 'Preview(_:body:)' declared here

/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/.build/checkouts/swiftui-math/Sources/SwiftUIMath/Math.swift:171:1: error: external macro implementation type 'PreviewsMacros.SwiftUIView' could not be found for macro 'Preview(_:body:)'; plugin for module 'PreviewsMacros' not found
169 | }
170 | 
171 | #Preview("Text Style") {
    | `- error: external macro implementation type 'PreviewsMacros.SwiftUIView' could not be found for macro 'Preview(_:body:)'; plugin for module 'PreviewsMacros' not found
172 |   Math("\\int_0^1 x^2\\,dx = \\frac{1}{3}")
173 |     .mathTypesettingStyle(.text)

SwiftUI.Preview:2:41: note: 'Preview(_:body:)' declared here
1 | @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
2 | @freestanding(declaration) public macro Preview(_ name: String? = nil, @ViewBuilder body: @escaping @MainActor () -> any View) = #externalMacro(module: "PreviewsMacros", type: "SwiftUIView")
  |                                         `- note: 'Preview(_:body:)' declared here

/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/.build/checkouts/swiftui-math/Sources/SwiftUIMath/Math.swift:178:1: error: external macro implementation type 'PreviewsMacros.SwiftUIView' could not be found for macro 'Preview(_:body:)'; plugin for module 'PreviewsMacros' not found
176 | }
177 | 
178 | #Preview("Large Operators") {
    | `- error: external macro implementation type 'PreviewsMacros.SwiftUIView' could not be found for macro 'Preview(_:body:)'; plugin for module 'PreviewsMacros' not found
179 |   Math("\\lim_{n\\to\\infty}\\sum_{k=1}^{n}\\frac{1}{k^2}=\\frac{\\pi^2}{6}")
180 |     .mathTypesettingStyle(.display)

SwiftUI.Preview:2:41: note: 'Preview(_:body:)' declared here
1 | @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
2 | @freestanding(declaration) public macro Preview(_ name: String? = nil, @ViewBuilder body: @escaping @MainActor () -> any View) = #externalMacro(module: "PreviewsMacros", type: "SwiftUIView")
  |                                         `- note: 'Preview(_:body:)' declared here

/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/.build/checkouts/swiftui-math/Sources/SwiftUIMath/Math.swift:185:1: error: external macro implementation type 'PreviewsMacros.SwiftUIView' could not be found for macro 'Preview(_:body:)'; plugin for module 'PreviewsMacros' not found
183 | }
184 | 
185 | #Preview("Matrix") {
    | `- error: external macro implementation type 'PreviewsMacros.SwiftUIView' could not be found for macro 'Preview(_:body:)'; plugin for module 'PreviewsMacros' not found
186 |   Math("A=\\begin{pmatrix}1&2\\\\3&4\\end{pmatrix}")
187 |     .mathTypesettingStyle(.display)

SwiftUI.Preview:2:41: note: 'Preview(_:body:)' declared here
1 | @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
2 | @freestanding(declaration) public macro Preview(_ name: String? = nil, @ViewBuilder body: @escaping @MainActor () -> any View) = #externalMacro(module: "PreviewsMacros", type: "SwiftUIView")
  |                                         `- note: 'Preview(_:body:)' declared here

/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/.build/checkouts/swiftui-math/Sources/SwiftUIMath/Math.swift:192:1: error: external macro implementation type 'PreviewsMacros.SwiftUIView' could not be found for macro 'Preview(_:body:)'; plugin for module 'PreviewsMacros' not found
190 | }
191 | 
192 | #Preview("Cases") {
    | `- error: external macro implementation type 'PreviewsMacros.SwiftUIView' could not be found for macro 'Preview(_:body:)'; plugin for module 'PreviewsMacros' not found
193 |   Math("\\begin{cases} x + y = 5 \\\\ 2x - y = 1 \\end{cases}")
194 |     .mathTypesettingStyle(.display)

SwiftUI.Preview:2:41: note: 'Preview(_:body:)' declared here
1 | @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
2 | @freestanding(declaration) public macro Preview(_ name: String? = nil, @ViewBuilder body: @escaping @MainActor () -> any View) = #externalMacro(module: "PreviewsMacros", type: "SwiftUIView")
  |                                         `- note: 'Preview(_:body:)' declared here

/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/.build/checkouts/swiftui-math/Sources/SwiftUIMath/Math.swift:199:1: error: external macro implementation type 'PreviewsMacros.SwiftUIView' could not be found for macro 'Preview(_:body:)'; plugin for module 'PreviewsMacros' not found
197 | }
198 | 
199 | #Preview("Accents And Scripts") {
    | `- error: external macro implementation type 'PreviewsMacros.SwiftUIView' could not be found for macro 'Preview(_:body:)'; plugin for module 'PreviewsMacros' not found
200 |   Math("\\hat{x}+\\bar{y}+\\vec{z}+a_{i}^{2}")
201 |     .mathTypesettingStyle(.text)

SwiftUI.Preview:2:41: note: 'Preview(_:body:)' declared here
1 | @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
2 | @freestanding(declaration) public macro Preview(_ name: String? = nil, @ViewBuilder body: @escaping @MainActor () -> any View) = #externalMacro(module: "PreviewsMacros", type: "SwiftUIView")
  |                                         `- note: 'Preview(_:body:)' declared here

/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/.build/checkouts/swiftui-math/Sources/SwiftUIMath/Math.swift:206:1: error: external macro implementation type 'PreviewsMacros.SwiftUIView' could not be found for macro 'Preview(_:body:)'; plugin for module 'PreviewsMacros' not found
204 | }
205 | 
206 | #Preview("Multicolor") {
    | `- error: external macro implementation type 'PreviewsMacros.SwiftUIView' could not be found for macro 'Preview(_:body:)'; plugin for module 'PreviewsMacros' not found
207 |   Math("\\color{#cc0000}{a}+\\color{#00aa00}{b}+\\color{#0000cc}{c}")
208 |     .mathTypesettingStyle(.text)

SwiftUI.Preview:2:41: note: 'Preview(_:body:)' declared here
1 | @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
2 | @freestanding(declaration) public macro Preview(_ name: String? = nil, @ViewBuilder body: @escaping @MainActor () -> any View) = #externalMacro(module: "PreviewsMacros", type: "SwiftUIView")
  |                                         `- note: 'Preview(_:body:)' declared here

/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/.build/checkouts/swiftui-math/Sources/SwiftUIMath/Math.swift:214:1: error: external macro implementation type 'PreviewsMacros.SwiftUIView' could not be found for macro 'Preview(_:body:)'; plugin for module 'PreviewsMacros' not found
212 | }
213 | 
214 | #Preview("Multicolor 2") {
    | `- error: external macro implementation type 'PreviewsMacros.SwiftUIView' could not be found for macro 'Preview(_:body:)'; plugin for module 'PreviewsMacros' not found
215 |   Math("\\textcolor{#ff8800}{\\int_0^1 x^2\\,dx}=\\textcolor{#0088ff}{\\frac{1}{3}}")
216 |     .mathRenderingMode(.multicolor)

SwiftUI.Preview:2:41: note: 'Preview(_:body:)' declared here
1 | @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
2 | @freestanding(declaration) public macro Preview(_ name: String? = nil, @ViewBuilder body: @escaping @MainActor () -> any View) = #externalMacro(module: "PreviewsMacros", type: "SwiftUIView")
  |                                         `- note: 'Preview(_:body:)' declared here

/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/.build/checkouts/swiftui-math/Sources/SwiftUIMath/RenderingMode.swift:26:14: error: external macro implementation type 'SwiftUIMacros.EntryMacro' could not be found for macro 'Entry()'; plugin for module 'SwiftUIMacros' not found
24 | 
25 | extension EnvironmentValues {
26 |   @Entry var mathRenderingMode: Math.RenderingMode = .monochrome
   |              `- error: external macro implementation type 'SwiftUIMacros.EntryMacro' could not be found for macro 'Entry()'; plugin for module 'SwiftUIMacros' not found
27 | }
28 | 

SwiftUI.Entry:1:75: note: 'Entry()' declared here
1 | @attached(accessor) @attached(peer, names: prefixed(__Key_)) public macro Entry() = #externalMacro(module: "SwiftUIMacros", type: "EntryMacro")
  |                                                                           `- note: 'Entry()' declared here

/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/.build/checkouts/swiftui-math/Sources/SwiftUIMath/TypesettingStyle.swift:21:14: error: external macro implementation type 'SwiftUIMacros.EntryMacro' could not be found for macro 'Entry()'; plugin for module 'SwiftUIMacros' not found
19 | 
20 | extension EnvironmentValues {
21 |   @Entry var mathTypesettingStyle: Math.TypesettingStyle = .display
   |              `- error: external macro implementation type 'SwiftUIMacros.EntryMacro' could not be found for macro 'Entry()'; plugin for module 'SwiftUIMacros' not found
22 | }
23 | 

SwiftUI.Entry:1:75: note: 'Entry()' declared here
1 | @attached(accessor) @attached(peer, names: prefixed(__Key_)) public macro Entry() = #externalMacro(module: "SwiftUIMacros", type: "EntryMacro")
  |                                                                           `- note: 'Entry()' declared here
```

## 产物

```
(无)
```
