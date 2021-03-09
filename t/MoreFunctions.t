# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl MoreFunctions.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More tests => 1;
BEGIN { use_ok('XML::LibXML::MoreFunctions') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use XML::LibXML;
use Data::Dumper;

my $xpc = 'XML::LibXML::XPathContext'->new ();
$xpc->registerNs (f => 'http://fxtran.net/#syntax');


&XML::LibXML::MoreFunctions::registerFunctions ($xpc);


my $doc = 'XML::LibXML'->load_xml (string => << 'EOF');
<doc>
XX<a-stmt/>Z
XX<b-stmt/>Y
</doc>
EOF

print STDERR $doc;

my @n;

@n = map { $_->toString } $xpc->findnodes ('.//a-stmt', $doc);

print STDERR &Dumper (\@n);

@n = map { $_->toString } $xpc->findnodes ('.//*[name ()="a-stmt"]', $doc);

print STDERR &Dumper (\@n);

@n = map { $_->toString } $xpc->findnodes ('.//*[ends-with(name (),"-stmt")]', $doc);

print STDERR &Dumper (\@n);

@n = $xpc->findvalue ('string-join (.//node (),"--")', $doc);

print STDERR &Dumper (\@n);

@n = $xpc->findvalue ('concat ("ab","cd")', $doc);

print STDERR &Dumper (\@n);


$doc = 'XML::LibXML'->load_xml (location => 'acpcmt.F90.xml');


@n = $xpc->findnodes ('.//f:named-E[./f:N/f:n/text ()="PQLCONV"]', $doc);

for (@n)
  {
    print STDERR $_->textContent, "\n";
  }

print STDERR "---------\n";


@n = $xpc->findnodes ('.//f:named-E[string-join(./f:N/f:n/text ())="PQLCONV"]', $doc);

for (@n)
  {
    print STDERR $_->textContent, "\n";
  }









