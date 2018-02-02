source $VIMRUNTIME/mswin.vim
behave mswin
set spelllang=en
set spellfile=home/jsmith/googledrive/vim/spell/en.utf-8.add
set spell
set sessionoptions+=resize,winpos
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
if has("gui_running")
  if has("gui_gtk3")
    set guifont=Inconsolata\ 12
  elseif has("gui_macvim")
    set guifont=Menlo\ Regular:h14
  elseif has("gui_win32")
    set guifont=Consolas:h11:cANSI
  endif
endif
colorscheme slate
syntax on 
execute pathogen#infect() 
let g:session_autoload = 'yes'
let g:session_autosave = 'yes'
let NERDTreeShowBookmarks=1
function! DisplayColorSchemes()
   let currDir = getcwd()
   exec "cd $VIMRUNTIME/colors"
   for myCol in split(glob("*"), '\n')
      if myCol =~ '\.vim'
         let mycol = substitute(myCol, '\.vim', '', '')
         exec "colorscheme " . mycol
         exec "redraw!"
         echo "colorscheme = ". myCol
         sleep 2
      endif
   endfor
   exec "cd " . currDir
endfunction


