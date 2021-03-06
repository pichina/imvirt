# ImVirt - I'm virtualized?
#
# Authors:
#   Thomas Liske <liske@ibh.de>
#
# Copyright Holder:
#   2009 - 2013 (C) IBH IT-Service GmbH [http://www.ibh.de/]
#
# License:
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this package; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
#

package ImVirt::Utils::procfs;

use strict;
use warnings;
use File::Slurp;
require Exporter;
our @ISA = qw(Exporter);

our @EXPORT = qw(
    procfs_getmp
    procfs_isdir
    procfs_isfile
    procfs_read
    procfs_starttime
);

our $VERSION = '0.2';

my $procdir = '/proc';

sub procfs_getmp() {
    return $procdir;
}

sub procfs_isdir($) {
    return -d join('/', procfs_getmp(), shift);
}

sub procfs_isfile($) {
    return -f join('/', procfs_getmp(), shift);
}

sub procfs_read($) {
    my $fn = join('/', procfs_getmp(), shift);
    if(-r $fn) {
	my $f = read_file($fn);
	chomp($f);
	return $f;
    }

    return undef;
}

sub procfs_starttime($) {
    my $fn = join('/', procfs_getmp(), shift, 'stat');
    if(-r $fn) {
	my @f = split(/\s/, read_file($fn));
	return $f[21];
    }

    return undef;
}

1;
