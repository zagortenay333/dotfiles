syn keyword Red execve fork exit goto break return continue
syn keyword cType bool s8 s16 s32 s64 u8 u16 u32 u64 f32 f64

" Highlight Tokens_That_Look_Like_This. It's a type hopefully.
syn match cType "\<\u\w*\l\+\w*\>"

" Highlight the first of 2 consecutive identifiers. It's a type hopefully.
syn match cType "^#\@<!\<\w*\> \+\(\<\w*\>\)\@="

" syn match cType "}\@<=\s*\w*"
" syn match cType "\w\+\(\s\*\w\)\@="
" syn match cType "\w\+\(\s*\*\W\)\@="
" syn match cType "(\@<=\w\+\()\s*{\s*[0.]\)\@="
" syn match cType "\(^\s*#.*\)\@<!\w\+\s\+\(\w\+\)\@="

hi! def link cIncluded Normal
hi! def link cType Type
hi! def link cStructure Type
hi! def link cStorageClass Type
" To prevent incorrect highlighting of compound literals.
hi! def link cErrInParen Normal
