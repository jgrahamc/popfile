#
# $Id$

package Text::Kakasi;

=head1 NAME

Text::Kakasi - kakasi library module for perl

=head1 SYNOPSIS

  use Text::Kakasi;

  $res = Text::Kakasi::getopt_argv('kakasi', '-ieuc', '-w');
  $str = Text::Kakasi::do_kakasi('日本語の文字列');

=head1 DESCRIPTION

このモジュールは、高橋裕信さんの作成されたソフトウェアKAKASIを
perlから用いるためのものです。

=over 4

=item getopt_argv($arg1, $arg2, ...)

KAKASIに与えるべきオプションを指定し、初期化を行います。オプションは、
kakasiコマンドで用いられるものに準じます。
また、一番最初のオプションはプログラムのファイル名です。
getopt_argvを呼び出すと、辞書ファイルがopenされます。これは、
close_kanwadicを呼び出すまでオープンされたままになります。

例えば、次のような引数でkakasiを実行したときと同じ効果を得るためには、

$ kakasi C<-ieuc> C<-w>

次のような引数でgetopt_argvを呼び出します。

getopt_argv('kakasi', 'C<-ieuc>', 'C<-w>');

=item do_kakasi($str)

引数に与えられた文字列に対して処理を行い、結果を文字列として返します。

=item close_kanwadic()

オープンしていた辞書ファイルをcloseします。
バージョン0.10では、2回以上getopt_argvを何度も呼び出す場合には、その
前にclose_kanwadicを呼び出す必要がありましたが、0.11移行ではgetopt_argv
内部で必要があればcloseするので、この関数は必ずしも呼び出す必要は
ありません。

=back

=head1 COPYRIGHT

Copyright (C) 1998, 1999, 2000 NOKUBI Takatsugu <knok@daionet.gr.jp>

このモジュールは完全に無保証です。

また、このモジュールはGNU General Public Licenceのもとで再配付、
改変が認められています。詳細については付属のCOPYINGというファイルを
参照して下さい。

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

=cut

require Exporter;
require DynaLoader;

@ISA = qw(Exporter DynaLoader);

@EXPORT_OK = qw(getopt_argv do_kakasi close_kanwadict);
%EXPORT_TAGS = (all => [qw(getopt_argv do_kakasi close_kanwadict)]);

$VERSION = '1.05';

bootstrap Text::Kakasi $VERSION;

1;
__END__
