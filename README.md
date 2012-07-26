rubber stamp (alpha)
====================

**rubber stamp** is a tool that is intended to allow the programmer to specify text to be substituted into source files, similar to the manner in which [RCS keywords][rcskeywords] function.

*rubber stamp* preserves comment decorations and the substituted text is encoded as a [netstring][netstring].

features
--------

* substitute string specified on command line.
* substitute contents of text file.
* preserves comment decorations.

usage
-----

you can use rubber stamp to maintain [vim][vim] modelines, amongst other things. for example, the following text in a source file:

`# $vimode$`

can be transformed into the following:

`# $vimode:46: vi: set softtabstop=8 shiftwidth=8 expandtab:,$`

by invoking rubber stamp with the following arguments:

`rubrstmp -f FILE vimode=' ex: set softtabstop=8 shiftwidth=8 expandtab:'`

successive substitutions will work in the same manner. for example,

`rubrstmp -f FILE vimode=' ex: set softtabstop=3 shiftwidth=3 expandtab:'`

on the resulting output yields:

`# $vimode:46: vi: set softtabstop=3 shiftwidth=3 expandtab:,$`

multi-line substititution is supported as well. for example, a legal notice can be substituted into a source file in the same manner. 

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

requirements
------------

*rubber stamp* requires [ruby][ruby]. only ruby 1.8.7 has been tested but other versions may work also.

license
-------

*rubber stamp* source code is provided under the *New BSD License*.

see [the license file][license] in the source distribution for more details about the license terms.

-----

**README.markdown for rubber stamp** by [michael lowell roberts][fmrl].   
copyright &copy; 2012, michael lowell roberts.  
all rights reserved.  
licensed under the [*New BSD License*][license].

[fmrl]: http://fmrl.org
[license]: http://github.com/fmrl/rubrstmp/blob/master/LICENSE.markdown
[netstring]: http://cr.yp.to/proto/netstrings.txt
[rcskeywords]: http://babbage.cs.qc.edu/courses/cs701/Handouts/rcs_keywords.html
[ruby]: http://www.ruby-lang.org
[vim]: http://www.vim.org
