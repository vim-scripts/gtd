" Vim filetype plugin file
" Language:     GTD
" Maintainer:   William Bartholomew <william@bartholomew.id.au>
" Last Change:  2006-05-25

if exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

" allow @ and : in keywords
setlocal iskeyword="a-z,A-Z,0-9,@,:"
noremenu <silent> &GTD.&New\ Task	:call <SID>GtdNewTask()<CR>
noremenu <silent> &GTD.Mark\ &Done	:call <SID>GtdMarkDone()<CR>
noremenu <silent> &GTD.Add\ &Context	:call <SID>GtdPromptAddContext()<CR>
noremenu <silent> &GTD.Assign\ &Project	:call <SID>GtdAssignProject()<CR>
noremenu <silent> &GTD.Re-&Sort		:call <SID>GtdSort()<CR>:write<CR>

" Add mappings, unless the user didn't want this.
if !exists("no_plugin_maps") && !exists("no_gtd_maps")
    noremap  <silent> <LocalLeader>n	:call <SID>GtdNewTask()<CR>
    noremap  <silent> <LocalLeader>d	:call <SID>GtdMarkDone()<CR>
    noremap  <silent> <LocalLeader>c	:call <SID>GtdPromptAddContext()<CR>
    noremap  <silent> <LocalLeader>p	:call <SID>GtdAssignProject()<CR>
    noremap  <silent> <LocalLeader>s	:call <SID>GtdSort()<CR>
endif

function! s:GtdNewTask()
    let task = input( "What is the task? " )
    if task != ""
	if match( getline( "." ), "^$" ) == 0
	    call setline( ".", task )
	else
	    call append( 0, task )
	endif
	call <SID>GtdSort()
	write

	let [lnum, col] = searchpos( "^" . task . "$" )
	call cursor( [lnum, col] )
    endif
endfunction

function! s:GtdMarkDone()
    let current_line = getline( "." )

    if !<SID>GtdIsTaskDone( current_line )
	let current_time = strftime("%Y%m%d")

	call setline( ".", "x:" . current_time . " " . current_line )
	call <SID>GtdSort()
	write
    endif
endfunction

function! s:GtdAssignProject()
    let project_name = input( "What is the project? " )
    if project_name != ""
	let project_tag = "p:" . project_name

	let current_line = getline( "." )
	if stridx( current_line, "p:" ) == -1
	    call setline( ".", project_tag . " " . current_line )
	else
	    call setline( ".", substitute( current_line, "p:\\S\\+", project_tag, "" ) )
	endif

	call <SID>GtdSort()
	write
    endif
endfunction

function! s:GtdAddContext( context_name )
    let current_line = getline( "." )

    if stridx( a:context_name, "@" ) == -1
	let context_name = "@" . a:context_name
    else
	let context_name = a:context_name
    endif

    if stridx( current_line, context_name ) == -1
	let new_line = substitute( current_line, "^\\(p:\\S\\+\\s\\?\\)\\?", "\\1" . context_name . " ", "" )
	call setline( ".", new_line )

	call <SID>GtdSort()
	write
    endif
endfunction

function! s:GtdPromptAddContext()
    let context_name = input( "What is the context? " )

    if context_name != ""
	call <SID>GtdAddContext( context_name )
    endif
endfunction

function! s:GtdIsTaskDone( task )
    return ( match( a:task, "^x[ :]" ) > -1 )
endfunction

function! s:GtdSort()
    if executable( "sort" )
	%! sort
    endif
endfunction

