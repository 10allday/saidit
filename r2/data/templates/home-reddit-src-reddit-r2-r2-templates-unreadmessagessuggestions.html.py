# -*- coding:utf-8 -*-
from mako import runtime, filters, cache
UNDEFINED = runtime.UNDEFINED
__M_dict_builtin = dict
__M_locals_builtin = locals
_magic_number = 9
_modified_time = 1508535884.116706
_enable_loop = True
_template_filename = '/home/reddit/src/reddit/r2/r2/templates/unreadmessagessuggestions.html'
_template_uri = '/unreadmessagessuggestions.html'
_source_encoding = 'utf-8'
from r2.lib.filters import websafe, unsafe, conditional_websafe
from pylons import request
from pylons import tmpl_context as c
from pylons import app_globals as g
from pylons.i18n import _, ungettext
_exports = []


def render_body(context,**pageargs):
    __M_caller = context.caller_stack._push_frame()
    try:
        __M_locals = __M_dict_builtin(pageargs=pageargs)
        __M_writer = context.writer()
        # SOURCE LINE 22
        __M_writer(u'\n<span class="next-suggestions">\n  ')
        # SOURCE LINE 24
        __M_writer(conditional_websafe(_('or')))
        __M_writer(u'\n  <span class="mark-all-read-container">\n    <a class="basic-button mark-all-read" href="#">')
        # SOURCE LINE 26
        __M_writer(conditional_websafe(_('mark all as read')))
        __M_writer(u'</a>\n    <span class="throbber">')
        # SOURCE LINE 27
        __M_writer(conditional_websafe(_('(this may take a while)')))
        __M_writer(u'</span>\n  </span>\n</span>\n')
        return ''
    finally:
        context.caller_stack._pop_frame()


