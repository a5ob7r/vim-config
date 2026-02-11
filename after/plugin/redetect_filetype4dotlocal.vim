vim9script

# This plugin is located in '$MYVIMDIR/after/' because filetype re-detection
# for '~/.local.xxx' should be invoked after all of other filetype detections
# are completed, such as ":filetype on" and 'pack/*/start/ftdetect/*.vim'.

# Re-detect a filetype for '~/.local.xxx' as '~/.xxx'.
def RedetectFiletype4DotLocal(afile: string)
  const head = fnamemodify(afile, ':p:h')
  const tail = fnamemodify(afile, ':t')

  if head !=# $HOME || tail !~# '^\.local'
    return
  endif

  const not_dotlocal_tail = tail[6 :] # strip '.local'(6 chars) prefix.
  const fname = fnameescape($'{head}/{not_dotlocal_tail}')

  execute $'doautocmd filetypedetect BufRead,BufNewFile {fname}'
enddef

def FiletypeRedetection4DotLocal(enable: bool)
  augroup vimrc:FiletypeRedetection4DotLocal
    autocmd!

    if enable
      # Re-detect a filetype for '~/.local.xxx' if filetype detection is unsuccessful.
      #
      # NOTE: This filetyype re-detection works correctly only if enabled just
      # after executing ":filetype on".
      autocmd BufRead,BufNewFile ~/.local.* {
        if empty(&filetype)
          expand('<afile>')->RedetectFiletype4DotLocal()
        endif
      }
    endif
  augroup END
enddef

command! EnableFiletypeRedetection4DotLocal {
  FiletypeRedetection4DotLocal(true)
}

command! DisableFiletypeRedetection4DotLocal {
  FiletypeRedetection4DotLocal(false)
}

EnableFiletypeRedetection4DotLocal
