"=============================================================================
" FILE: syntastic-perl-inc.vim
" AUTHOR:  Yuki Takahashi <yuki.takahashi.1126@gmail.com>
" Last Modified: 2 Mar 2014.
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" Version: 1.0
"=============================================================================

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:archname = unite#util#system('perl -MConfig -e '."'".'print $Config{archname}'."'")
let s:perl_project_root_files = ['.git', '.gitmodules', 'Makefile.PL', 'Build.PL', 'Cpanfile', 'cpanfile']
let s:perl_lib_dirs = ['lib', 'extlib', 'local/lib/perl5', 'local/lib/perl5/'.s:archname]

function! s:get_current_directory()
    return fnamemodify(getcwd(), ':p')
    "return expand("%:p:h")
endfunction

function! s:get_root_directory(current_dir)
    if a:current_dir ==# '/'
        return ''
    endif

    for root_file in s:perl_project_root_files
        if glob(a:current_dir . root_file) !=# ''
            return a:current_dir
        end
    endfor
    return s:get_root_directory([simplify(a:current_dir.'/../')], s:perl_project_root_files)
endfunction

function! s:uniq(list)
    return filter(copy(a:list), 'count(a:list, v:val) != 0')
endfunction

function! syntastic_perl_inc#resolve_local_paths()
    let project_root_path = s:get_root_directory(s:get_current_directory())
    let perl_lib_dirs = copy(s:perl_lib_dirs)
    call extend(perl_lib_dirs, a:perl_paths)
    let inc_paths = s:uniq(map(perl_lib_dirs, 'simplify(project_root_path . "/" . v:val)'))
    let original_paths = split(&path, ',')
    call extend(inc_paths, original_paths)
    let g:syntastic_perl_lib_path=inc_paths
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

