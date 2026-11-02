# Đối chiếu mã commit sau khi viết lại lịch sử (02/11/2026)

Ngày 02/11/2026 repo chuyển từ `thevuong/dau` sang `codefastlabs/dau` và lịch sử được viết lại để bỏ một từ mẫu cũ khỏi mọi phiên bản (người dùng yêu cầu). Mã của mọi commit đều đổi. Các mã commit ghi trong tài liệu trước ngày này (PROGRESS, COMPATIBILITY…) là mã cũ: tra bảng dưới để ra mã mới. Hai commit chỉ dùng để thay từ đó trở thành rỗng nên bị bỏ (ghi "—").

| Mã cũ | Mã mới | Commit |
|---|---|---|
| 037d1b7 | 8a4b795 | docs: bring README, ARCHITECTURE and PROGRESS up to date after M2 audit |
| 03c385c | 9e09753 | docs: N4 allows user-clicked enable/uninstall; host app runs unsandboxed (D37) |
| 0420967 | 2e8dc15 | feat(imk): wire VietEngine into the input controller |
| 06f0dcb | 9d5e3e0 | build: add XcodeGen project with host app and IMK input method targets |
| 073bc75 | 54b01d4 | refactor(shared): remove unused SettingsExamples |
| 08f3281 | 82d9ecc | fix(imk): leave Backspace to the app so Chromium does not delete twice |
| 09be6dc | 7152554 | test(scripts): self test settings sharing over the App Group without typing |
| 0aa4872 | 63efd3f | feat(inputmethod): read shared settings and apply per-app start modes |
| 0ac50c3 | cbb8179 | test(compat): run the matrix in Edge, Firefox, Notes and Mail |
| 0b188dd | 1965c43 | fix: show Dấu as display name in English locales |
| 0c6d631 | 632882b | docs: log first M4 audit |
| 0c8e44b | 1042ff4 | fix(app): pin the host app to its Vietnamese localization |
| 0cbef3c | e769edd | fix(app): show full section names in the Settings sidebar |
| 0cdcffa | df8a7a6 | fix(app): split the Apps search field and + into two system controls |
| 0d3f6f0 | f8d8814 | test(scripts): force underline in typing self test and guard keystrokes |
| 0f5baee | 3ea6598 | docs: note per-document input source and zsh log builtin in M2 checklist |
| 1426f85 | 26e81dc | feat(app): add temporary app icon and set version 0.1.0 |
| 161e0da | 6b2bc52 | docs: log M4 settings window |
| 163bd27 | 63bcf96 | test(engine): pin doubled tone letters in English words |
| 17c1a90 | 153c470 | docs: allow place-name spellings and record VNI digit rule |
| 19be7b0 | 1a14742 | docs: record the underline trial results |
| 19fd8f1 | 4fbfdbd | fix(engine): reject iê without initial, yê after consonant and c before oa/uy |
| 1b6a946 | e169a04 | docs: log right-gutter fix and UI checks |
| 1bc88c8 | c4556bb | chore(scripts): add Settings snapshot renderer and sample checks |
| 1e0f358 | e3a4107 | docs: log apps header fix |
| 1f82d36 | 02288b6 | docs: plan milestone M3 |
| 22cb876 | e394d80 | test(engine): cite D28 and D36 for distant transforms and VNI digits |
| 258f3a5 | 005bc1d | docs: the multi-display tint was the missing mode-level template flag, now fixed |
| 25c0038 | 5c4f8e6 | docs: log Chrome manual test result |
| 27ed9c6 | 310d7aa | docs: note the stale TIS cache after changing the input method bundle ID |
| 285b873 | d1ea61a | feat(im): add underline (marked text) mode per app rule (D13) |
| 2ad149b | 4234176 | docs: log app icon match |
| 2d59abf | 54263ed | docs: add the compatibility matrix skeleton for M3 |
| 2d6206e | 5611253 | feat(shared): add shared settings model, store and engine previews |
| 2e78e83 | — | (bỏ: commit rỗng sau khi viết lại) |
| 31a04b3 | fc6d3d7 | feat(engine): accept place-name spellings with k and kr (D31) |
| 3378b6e | — | (bỏ: commit rỗng sau khi viết lại) |
| 36c2771 | 1cdcd69 | fix(im): draw the mode icon as a system-sized badge with the V cut out |
| 373db68 | 4d53e68 | fix(app): use system colors for sidebar tiles and an orange banner |
| 3a32279 | 0631a56 | test: replace the sample foreign word with Codefastlabs and Swift |
| 3b8864b | 1da2cfe | chore: rename bundle ID prefix to com.codefastlabs.dau (D24) |
| 3c70716 | fba9889 | fix(app): say tone keys go anywhere after a vowel |
| 3ffaee1 | 552530d | build: give the App Group its own identifier |
| 41fb745 | de76189 | docs: close M3 after the third audit |
| 439e0b1 | 7d16c90 | test(scripts): compare the Apps header with the mockup |
| 48c839c | 82cb116 | test(engine): cover VNI uppercase tones, classic hofa and erased-word lock |
| 495544d | 22f3e4d | docs: settle engine rules D28-D33 from OpenKey review |
| 49936c2 | 2085879 | feat(imk): add temporary V/E template icons for input modes |
| 4dcb7ef | cb350d5 | docs: log M4 audit fixes |
| 4ec0aaf | 1db92e5 | docs: record Backspace regression runs after the Chromium fix |
| 4fdd7ea | e3f955e | fix(app): let the add-rule sheet open the app picker in the sandbox |
| 50f039f | 435466a | docs: research install, enable, upgrade and uninstall for M5 |
| 511b913 | 4db2a41 | docs: log Safari manual test result |
| 53ed26b | 0b7440e | docs: log canvas icon and content updates |
| 53f79d0 | a999722 | docs: fill in the commit hash of the evidence log line |
| 54dee49 | 1d56511 | docs: log round + button fix |
| 55951bf | 406feae | docs: log sidebar icon fix |
| 55c00bb | 7a6f087 | docs: record the new mode icon and the multi-display tint limit |
| 572fbf5 | 463b4fe | docs: settle M3 audit 2 follow-ups and sync the canvas note |
| 5d1cb50 | 189deea | docs: align test docs with D4 x D20 and record M3 audit 1 follow-ups |
| 5e33e7c | 6082739 | docs: accept triple key for doubled tone letters in English words |
| 5f48b5d | 8186d37 | fix(scripts): let perf-report match app names, not only exact bundle IDs |
| 5f7b781 | 970af00 | docs: drop the English input mode (D2) and per-app mode rules (D5) |
| 604442a | 48dc8c9 | docs: record the VoiceOver check for D17 and defer the name check to M7 |
| 60dac6f | 96a3e41 | docs: log the suggestions section and re-enabled features |
| 6119be9 | a035faa | docs: record VNI engine measurements |
| 62a07f5 | 5f51fc8 | fix(app): let the page scroll view reach the window edge |
| 693271d | d8556d9 | fix(app): keep the Settings layout still between sections |
| 6cc1e1f | 32f7c01 | docs: update OpenKey notes for place-name spellings |
| 6e29f18 | 2850d33 | docs: close M2 and M4 after the third audit |
| 6e4f17a | dd2e3be | docs: define word boundary for restore, add D26 and D27 |
| 6fe660b | 323222c | docs: add README with build and test instructions |
| 72ead82 | 63633d6 | test(scripts): measure Settings layout and hint contrast in snapshots |
| 7449cf1 | fe729e8 | docs: record Safari IMK timing sample |
| 74fd2d0 | 924e3fb | docs: plan milestone M5 |
| 761a951 | 02df088 | docs: log M5 T2/T3 progress |
| 77ceedf | 7501689 | docs: settle D20, D28 and D33 details and add D35 |
| 784438b | a94b7b7 | docs: system colours only in the app (D9) |
| 7935a70 | e831c2d | chore: initialize repository with docs, agents and GPLv3 license |
| 7b07043 | 10b4b58 | docs: record self-tests passing with the new bundle ID |
| 7b3f815 | ec0d020 | test: use Sunrise as the sample foreign word |
| 7d28fb2 | fba761c | docs: sync engine API and OpenKey notes with M1 code |
| 7f94832 | fff7bfc | test(engine): pin ăk only when ă precedes k (D31) |
| 7fca31c | a85504f | docs: log app icon and settings redo |
| 829fcdd | 6d2127e | docs: record Telex engine measurements |
| 83ebc48 | 7da7631 | feat(app): list underline suggestions apart from stored rules |
| 867d3ad | b1fd4b7 | docs: keep ăk only when ă precedes k (D31) |
| 898da0e | 39ae9fb | docs: log settings UI sign-off |
| 89bc34c | 037e606 | docs: clarify when per-app modes apply (D5) |
| 8ab965e | 6c1c055 | feat(im): add marks to typed words (D20) and reset on unreported source changes |
| 8bddba8 | 6ef767e | feat(engine): add VNI input method |
| 8c45ac0 | bee4d8c | fix(im): size the V like the system's A in the mode icon |
| 8d8774b | c309073 | docs: clarify the D4 x D20 example and fill the cleanup commit hash |
| 8e8cc59 | aff1823 | docs: log M4 language and sidebar fixes |
| 9162fd8 | 99984c7 | docs: fix M2/M4 re-audit findings and record on-machine test results |
| 933565e | d29e4d8 | docs: settle place-name spelling option d in D31 |
| 94ada11 | 61daeec | feat(app): suggest underlining for Firefox on measurement (D13) |
| 954becf | 710664f | docs: keep system-drawn controls where they differ from the mockup (D9) |
| 958a5a8 | f70d365 | build: sign with the Personal Team so the App Group works |
| 9680c68 | 72dc03c | feat(inputmethod)!: single Vietnamese input mode, rules keep only underline |
| 9999122 | 8bf99cd | feat(imk): add key routing and cursor tracking with logic tests |
| 9b32e00 | 2a09f89 | docs: state that D20 applies after reset events and its read cost (N3) |
| 9e0dbf3 | 091e2d3 | test(scripts): check the real Settings window across scroll bar styles |
| a106bff | 6c9359f | test(scripts): allow the legacy scroll bar width in the layout check |
| a3073c2 | eee2486 | docs: log scroll header fix |
| a5045dc | 2ab98fb | fix(app): draw sidebar icons and segmented selection as in the mockup |
| a59c44f | 9a97207 | fix(engine): apply D20 prefix level on seeded words and D33 restore switch |
| a775289 | 52aa805 | chore(scripts): add debug install and perf report scripts |
| a89ef37 | f259f0e | feat(app): rebuild Settings layout after the mockup |
| aac260e | d8c3aa0 | docs: record Chrome IMK timing sample |
| ae72c26 | ddfee4a | docs: add M4 manual test checklist |
| aec6b1d | 0376f63 | docs: resolve engine rule conflicts found in M0 audit |
| b0739c7 | b0fc503 | docs: add OpenKey engine notes |
| b1de6f0 | 29b8210 | test(scripts): send Delete and switch input source in the typing self test |
| b23b266 | eb288b7 | fix(app): keep underlining unselectable in rule rows until M3 |
| b2a331d | a586712 | build: add DauEngine and DauShared Swift packages with Swift Testing scaffolds |
| b3d4a29 | 2d1e047 | docs: settle the domain and bundle ID prefix (D24) |
| b447b5d | 64eef9a | fix(app): match app icon marks to the brand mockup |
| b6be994 | f113c38 | docs: underline stays opt-in; the compatibility list only suggests (D13) |
| ba6a2b8 | 7c240ef | docs(engine): cite D28 and D35 in code and test comments |
| bc0cfdb | 14abd70 | docs: log M4 start |
| bcb1227 | b4f2cbe | fix(im): mark the input mode icon as template so the ⌃Space indicator shows it |
| bfcb958 | 7f57b3d | docs: log settings rebuild without Form |
| c1c4643 | 5954076 | docs: close M0 after passing audit |
| c233356 | 0394f54 | docs: note public GitHub repository |
| c3356a5 | 59a491f | feat(inputmethod): add "Cài đặt Dấu…" to the input menu |
| c59f512 | 7274ff6 | docs: record D20 cost and the input source reset measurements |
| c6f8315 | e4d2f22 | docs: log M2 input method build and place-name measurements |
| c731c61 | 25d0192 | feat(app): add Settings window with four sections |
| c99a458 | 1a9ff12 | docs: drop stale pending label in OpenKey notes |
| cacf832 | 04d939b | docs: align D11 and the A/B record with method A after M2 audit |
| cb44aa4 | c6f3301 | docs: close M1 after second audit and tidy D31 wording |
| cf5c2bb | a92b17b | feat(engine): add Telex and simple Telex VietEngine |
| cf8b74f | e3fa5ee | fix(app): keep the Apps + button round |
| d03d901 | 2f6cfeb | docs: record macOS autocorrect as a known D4 limit; drop the underline advice until M3 |
| d0bc215 | 4ae98ce | docs: update M2 status after fork hand-back |
| d1b74f8 | 9c914cf | feat(app): install, enable, upgrade and uninstall the input method (M5 T3) |
| d5f0123 | 289c59b | docs: add M2 manual typing checklist |
| d60457b | f569e58 | docs: log spelling tightening and M2 start |
| d6aa417 | 2faacb9 | fix(app): match the Settings window to the mockup |
| d922a70 | 26dbcaf | fix(app): mark underlining and adding marks to typed words as not yet available |
| da3ae8d | 981af00 | fix(app): show the scroll bar and cover scrolled content under the header |
| db3c111 | 1e88f9e | docs: log layout-shift and HIG colour fix |
| ddb38c8 | 48b6bb6 | test(scripts): compare Settings snapshots with the mockup artboards |
| deddc49 | 1d0e5aa | feat(app): add the three-step onboarding window |
| e08d265 | 13812d1 | docs: clarify D20 validity check keeps displayed diacritics |
| e0bb918 | a823268 | docs: record self-typed results for VS Code and Terminal |
| e444440 | 08b063d | docs: record M0 verification and M1 research progress |
| e7da5e6 | 2b49c58 | feat(app): suggest underline from a bundled compatibility list and enable finished features |
| ea03f87 | a767727 | docs: record first IMK timing samples |
| ea676ae | 4ddd241 | feat(app): drop English mode UI, show the per-window input source option |
| ebfce9a | 3995b7f | test(engine): measure handle cost per key on a long mixed text |
| ec5701e | ad6e563 | test(inputmethod): diagnose replacements and type into real apps |
| ecd81b3 | 8a105dc | test(engine): measure VNI handle cost per key |
| f153102 | 1a52549 | docs: settle the scope of adding marks to typed words (D20) |
| f3f3f3b | 120727d | docs: log TextEdit manual test result |
| f693b66 | 63093aa | docs: align OpenKey notes with settled decisions D26-D33 |
| fab8b95 | 618e513 | test(scripts): add sidebar and segmented close-up comparisons |
| fdad91d | 3d3028d | docs: settle the A/B question and amend N3 |
