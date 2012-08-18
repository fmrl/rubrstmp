rubrstmp 0.1.0
==============

**rubrstmp** is a tool that is intended to allow the programmer to specify text to be substituted into source files, similar to the manner in which [RCS keywords][rcskeywords] function.

*rubrstmp* preserves comment decorations. the substituted text is encoded as a [netstring][netstring], which simplifies parsing considerably. please bear in mind, however, that the use of netstrings presents a minor inconvenience: the resulting file incompatible with automated elimination of trailing whitespace and automated space/tab conversion. 

features
--------

* substitute string specified on command line.
* substitute contents of text file.
* preserves comment decorations.
* [rake][rake] integration:
   * search directory for files to substitute.
   * ignores binaries.
   * explicit exclusion of paths using globs.
   * recursion into projects that use *rubrstmp* and rake.
   * preview tasks with verbose output.

maturity
--------

*rubrstmp* is still an alpha quality product. i trust it enough to use it on my own projects but it will be some time before i feel it is stable enough for a 1.0 release. please bear this in mind when using it.

also, please be aware that *rubrstmp* will overwrite your source files if you tell it to. while i believe it functions correctly, i cannot be responsible for data loss, even if it's due to a bug in *rubrstmp*. please exercise caution.

usage
-----

### from the shell

you can use *rubrstmp* to maintain [vim][vim] modelines, amongst other things. for example, the following text in a source file:

`# $vimode$`

can be transformed into the following:

`# $vimode:46: vi: set softtabstop=8 shiftwidth=8 expandtab:,$`

by invoking rubrstmp with the following arguments:

`rubrstmp -f FILE vimode=' ex: set softtabstop=8 shiftwidth=8 expandtab:'`

successive substitutions work in the same manner. for example,

`rubrstmp -f FILE vimode=' ex: set softtabstop=3 shiftwidth=3 expandtab:'`

on the resulting output yields:

`# $vimode:46: vi: set softtabstop=3 shiftwidth=3 expandtab:,$`

multi-line substitution is supported as well. for example, a legal notice can be substituted into a source file in the same manner. 

`# $legal$`

would be expanded into the following:

    # $legal:1570:
    # 
    # Copyright (c) 2012, Michael Lowell Roberts.
    # All rights reserved.
    # 
    # Redistribution and use in source and binary forms, with or without
    # modification, are permitted provided that the following conditions are
    # met:
    # 
    #   - Redistributions of source code must retain the above copyright
    #   notice, this list of conditions and the following disclaimer.
    # 
    #   - Redistributions in binary form must reproduce the above copyright
    #   notice, this list of conditions and the following disclaimer in the
    #   documentation and/or other materials provided with the distribution.
    # 
    #   - Neither the name of the copyright holder nor the names of
    #   contributors may be used to endorse or promote products derived
    #   from this software without specific prior written permission.
    # 
    # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
    # IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
    # TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
    # PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
    # OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    # SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
    # TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
    # PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
    # LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
    # NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    # SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
    # 
    # ,$

using the following arguments:

`rubrstmp -f FILE legal=@LICENSE.markdown`

*rubrstmp* is likely to be useful with git's smudge and clean filter feature; i haven't used it for this purpose yet, however.

### from within rake

to use *rubrstmp* within your *Rakefile*, please add the following code
to it and adapt it for your needs:

    require 'rubrstmp/rake_tasks'

    namespace :rubrstmp do
       exclude '*.md'
       recurse 'cmakes'
       file_keywords \
          'legal' => 'LICENSE.md',
          'vimmode' => 'rubrstmp/vimmode',
       string_keywords \
          'o-hai' => 'o, hai!'
    end

each command within the :rubrstmp namespace serves a specific purpose:

* **exclude** is used to specify glob patterns that describe which files you do not want *rubrstmp* to modify. you can specify multiple glob patterns separated by commas.
* **recurse** specifies subdirectories that contain projects that should be processed by invoking *rake* recursively. this is important for nested project directories with different license agreements, for example.
* **file_keywords** specifies what keywords should be expanded using the content of a file.
* **string_keywords** specified what keywords should be expanded using a string value.

requirements
------------

*rubrstmp* requires [ruby][ruby], [ruby gems][rubygems], and [bundler][bundler]. *bundler* will install all remaining dependencies upon invocation.

to-date, only ruby 1.8.7 has been tested but other versions may work also.

license
-------

*rubrstmp* source code is provided under the *New BSD License*.

see [the license file][license] in the source distribution for more details about the license terms.

-----

**README.markdown for rubrstmp** by [michael lowell roberts][fmrl].   
copyright &copy; 2012, michael lowell roberts.  
all rights reserved.  
licensed under the [*New BSD License*][license].

[bundler]: http://gembundler.com/
[fmrl]: http://fmrl.org
[license]: http://github.com/fmrl/rubrstmp/blob/master/LICENSE.markdown
[netstring]: http://cr.yp.to/proto/netstrings.txt
[rake]: http://rake.rubyforge.org/
[rcskeywords]: http://babbage.cs.qc.edu/courses/cs701/Handouts/rcs_keywords.html
[ruby]: http://www.ruby-lang.org
[rubygems]: http://rubygems.org/
[vim]: http://www.vim.org
