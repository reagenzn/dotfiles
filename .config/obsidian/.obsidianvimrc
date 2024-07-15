imap jj <Esc>
noremap H ^
noremap L $
noremap J 5j
noremap K 5k
set clipboard=unnamed
exmap back obcommand app:go-back
nmap <C-o> :back
exmap forward obcommand app:go-forward
nmap <C-i> :forward
exmap togglefold obcommand editor:toggle-fold
nmap zo :togglefold
nmap zc :togglefold
nmap za :togglefold

exmap jumpanywhere obcommand mrj-jump-to-link:activate-jump-to-anywhere
nmap f :jumpanywhere

exmap jumpToLink obcommand mrj-jump-to-link:activate-jump-to-link
nmap <Space>f :jumpToLink

exmap unfoldall obcommand editor:unfold-all
nmap zR :unfoldall

exmap foldall obcommand editor:fold-all
nmap zM :foldall

exmap splitv obcommand workspace:split-vertical
nmap sv :splitv

exmap splith obcommand workspace:split-horizontal
nmap ss :splith


exmap tabnext obcommand cycle-through-panes:cycle-through-panes
nmap gt :tabnext

exmap tabprev obcommand cycle-through-panes:cycle-through-panes-reverse
nmap gT :tabprev


exmap focusRight obcommand editor:focus-right
nmap <C-l> :focusRight

exmap focusLeft obcommand editor:focus-left
nmap <C-h> :focusLeft

exmap focusTop obcommand editor:focus-top
nmap <C-k> :focusTop

exmap focusBottom obcommand editor:focus-bottom
nmap <C-j> :focusBottom

exmap insertCallout obcommand editor:insert-callout
nmap <C-i> :insertCallout

exmap tableRowDelete obcommand editor:table-row-delete
nmap <C-d> :tableRowDelete

exmap openSearch obcommand editor:open-search
nmap <C-f> :openSearch

unmap <Space>
exmap test obcommand workspace:close
nmap <Space>q :test<CR>

exmap fuzzyFileSearch obcommand obsidian-another-quick-switcher:search-command_file-name-fuzzy-search
nmap <Space>p :fuzzyFileSearch<CR>

exmap backLink obcommand obsidian-another-quick-switcher:backlink
nmap <Space>o :backLink<CR>

exmap nextTab obcommand workspace:next-tab
nmap <Space>k :nextTab

exmap previousTab obcommand workspace:previous-tab
nmap <Space>j :previousTab


exmap openDailyNote obcommand daily-notes
nmap <Space>d :openDailyNote

exmap openPrevDailyNote obcommand daily-notes:goto-prev
nmap <Space>n :openPrevDailyNote

exmap openNextDailyNote obcommand daily-notes:goto-next
nmap <Space>m :openNextDailyNote

exmap showSuggestions obcommand various-complements:show-suggestions
nmap <Space>; :showSuggestions

exmap insertCurrentDate obcommand insert-current-date
nmap <Space>x :insertCurrentDate

exmap addProperty obcommand markdown:add-metadata-property
nmap <Space>a :addProperty

" exmap lintFile obcommand obsidian-linter:lint-file
" nmap <Space>f :lintFile

exmap showCalendar obcommand calendar:show-calendar-view
nmap <Space>c :showCalendar

exmap renameHeading obcommand editor:rename-heading
nmap <Space>r :renameHeading


exmap surround_wiki surround [[ ]]
exmap surround_double_quotes surround " "
exmap surround_single_quotes surround ' '
exmap surround_backticks surround ` `
exmap surround_tilda surround ~~ ~~
exmap surround_underline surround <u> </u>
exmap surround_brackets surround ( )
exmap surround_square_brackets surround [ ]
exmap surround_curly_brackets surround { }

" NOTE: must use 'map' and not 'nmap'
map [[ :surround_wiki
nunmap s
vunmap s
map s" :surround_double_quotes
map s' :surround_single_quotes
map s` :surround_backticks
map sb :surround_brackets
map sw :surround_wiki
map s( :surround_brackets
map s) :surround_brackets
map s~ :surround_tilda
map s[ :surround_square_brackets
map s] :surround_square_brackets
map s{ :surround_curly_brackets
map s} :surround_curly_brackets
map su :surround_underline

" Maps pasteinto to Ctr-p
map sa :pasteinto
