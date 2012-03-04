#!/usr/bin/perl -wT
# whitelists torrent file for peertracker
# by Matija Nalis <mnalis-peertracker@voyager.hr> 20120304 GPLv3+

use strict;
use Net::BitTorrent;
use DBI;

# XXX - you must change those to match your $_SERVER['tracker'] in tracker.mysql.php
my $db_host = 'localhost';
my $db_user = 'osmtracker';
my $db_pass = 'vutu3ohNe';
my $db_name = 'peertracker';
my $db_prefix = 'pt_';

# no user configurable parts below

my $torrent_filename = $ARGV[0] or die "Usage: $0 <filename.torrent> -- whitelist this torrent info_hash for peertracker";

die "$torrent_filename does not exist: $!" unless -r $torrent_filename;

my $client = Net::BitTorrent->new();
my $torrent = $client->add_torrent({Path => $torrent_filename}) or die "Cannot load torrent file $torrent_filename";

my $hash = $torrent->infohash();
#print "infohash is $hash\n";


my $dbh = DBI->connect("DBI:mysql:database=$db_name;host=$db_host", $db_user, $db_pass, { PrintError=>1, PrintWarn=>1, RaiseError=>1, AutoCommit=>1 }) or die $DBI::errstr;
my $sql = "INSERT INTO ${db_prefix}permissions SET info_hash=unhex(?), allow=1";
my $sth = $dbh->prepare($sql) or die $dbh->errstr();
$sth->execute($hash) or die $sth->errstr();

print "infohash $hash whitelisted OK.\n";
exit 0;
