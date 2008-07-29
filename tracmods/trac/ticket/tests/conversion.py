from trac.test import EnvironmentStub, Mock
from trac.util import sorted
from trac.ticket.model import Ticket
from trac.ticket.web_ui import TicketModule
from trac.mimeview.api import Mimeview
from trac.web.clearsilver import HDFWrapper
from trac.web.href import Href

import unittest


class TicketConversionTestCase(unittest.TestCase):

    def setUp(self):
        self.env = EnvironmentStub()
        self.ticket_module = TicketModule(self.env)
        self.mimeview = Mimeview(self.env)
        self.req = Mock(hdf=HDFWrapper(['./templates']),
                        base_path='/trac.cgi', path_info='',
                        href=Href('/trac.cgi'))

    def _create_a_ticket(self):
        # 1. Creating ticket
        ticket = Ticket(self.env)
        ticket['reporter'] = 'santa'
        ticket['summary'] = 'Foo'
        ticket['description'] = 'Bar'
        ticket['foo'] = 'This is a custom field'
        return ticket

    def test_conversions(self):
        conversions = self.mimeview.get_supported_conversions(
            'trac.ticket.Ticket')
        expected = sorted([('csv', 'Comma-delimited Text', 'csv',
                           'trac.ticket.Ticket', 'text/csv', 8,
                           self.ticket_module),
                          ('tab', 'Tab-delimited Text', 'tsv',
                           'trac.ticket.Ticket', 'text/tab-separated-values', 8,
                           self.ticket_module),
                           ('rss', 'RSS Feed', 'xml',
                            'trac.ticket.Ticket', 'application/rss+xml', 8,
                            self.ticket_module)],
                          key=lambda i: i[-1], reverse=True)
        self.assertEqual(expected, conversions)

    def test_csv_conversion(self):
        ticket = self._create_a_ticket()
        csv = self.mimeview.convert_content(self.req, 'trac.ticket.Ticket',
                                            ticket, 'csv')
        self.assertEqual((u'id,summary,reporter,owner,description,keywords,cc'
                          '\r\nNone,Foo,santa,,Bar,,\r\n',
                          'text/csv;charset=utf-8', 'csv'), csv)


    def test_tab_conversion(self):
        ticket = self._create_a_ticket()
        csv = self.mimeview.convert_content(self.req, 'trac.ticket.Ticket',
                                            ticket, 'tab')
        self.assertEqual((u'id\tsummary\treporter\towner\tdescription\tkeywords'
                          '\tcc\r\nNone\tFoo\tsanta\t\tBar\t\t\r\n',
                          'text/tab-separated-values;charset=utf-8', 'tsv'),
                         csv)

    def test_rss_conversion(self):
        ticket = self._create_a_ticket()
        content, mimetype, ext = self.mimeview.convert_content(
            self.req, 'trac.ticket.Ticket', ticket, 'rss')
        self.assertEqual(('<?xml version="1.0"?>\n<!-- RSS generated by Trac v '
                          'on  -->\n<rss version="2.0">\n <channel>\n   '
                          '<title>Ticket </title>\n  <link></link>\n  '
                          '<description>&lt;p&gt;\nBar\n&lt;/p&gt;\n'
                          '</description>\n  <language>en-us</language>\n  '
                          '<generator>Trac v</generator>\n </channel>\n</rss>\n',
                          'application/rss+xml', 'xml'),
                         (content.replace('\r', ''), mimetype, ext))


def suite():
    return unittest.makeSuite(TicketConversionTestCase, 'test')

if __name__ == '__main__':
    unittest.main()
