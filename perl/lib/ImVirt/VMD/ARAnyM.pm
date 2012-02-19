# ImVirt - I'm virtualized?
#
# $Id$
#
# Authors:
#   Thomas Liske <liske@ibh.de>
#
# Copyright Holder:
#   2012 (C) IBH IT-Service GmbH [http://www.ibh.de/]
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

package ImVirt::VMD::ARAnyM;

use strict;
use warnings;
use constant PRODUCT => '|ARAnyM';

use ImVirt;
use ImVirt::Utils::dmesg;
use ImVirt::Utils::uname;

ImVirt::register_vmd(__PACKAGE__);

sub detect($) {
    ImVirt::debug(__PACKAGE__, 'detect()');

    my $dref = shift;

    # Look for a dmesg line
    if(defined(my $m = dmesg_match(
	'NatFeats found \(ARAnyM,' => IMV_PTS_MAJOR,
     ))) {
	ImVirt::inc_pts($dref, $m, IMV_VIRTUAL, PRODUCT) if($m > 0);
    }
}

sub pres() {
    return (PRODUCT);
}

1;
