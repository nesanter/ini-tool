" Vim syntax file
" Language: "Simple Safe Settings" INI
" Maintainer: Noah Santer
" Latest Revision: 25 Feb 2019

" A modeline at the end of the INI file
" can be used to enable this syntax per-file:
" vim: set syn=sssini:

syn match sssiniRemoveKey "^\s*\zs[^=]\{-1,}\ze\s*$"

syn match sssiniAssign "^.\{-}=.*$" contains=sssiniKey,sssiniValue
syn match sssiniKey "^\s*\zs.\{-}\ze\s*=" contained
syn match sssiniValue "=\zs\s*.\{-1,}\s*\ze$" contained

syn match sssiniSection "^\s*\zs\[[^\]]*\]\ze\s*$" contains=sssiniSectionName
syn match sssiniSectionName "\[\zs[^\]]*\ze\]" contained

syn match sssiniComment "^\s*#.*$" contains=sssiniPound
syn match sssiniPound "#" contained

hi sssiniComment ctermbg=234 ctermfg=14
hi sssiniPound ctermbg=234 ctermfg=14

" hi sssiniSection ...
hi sssiniSectionName ctermfg=1

hi sssiniAssign ctermfg=6

hi sssiniKey ctermfg=3
hi sssiniRemoveKey ctermfg=3 cterm=strikethrough

hi sssiniValue cterm=italic
" hi sssiniValue ctermfg=144

let b:current_syntax = "sssini"
