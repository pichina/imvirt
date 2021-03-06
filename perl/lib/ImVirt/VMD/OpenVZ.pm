# ImVirt - I'm virtualized?
#
# Authors:
#   Thomas Liske <liske@ibh.de>
#
# Copyright Holder:
#   2009 - 2012 (C) IBH IT-Service GmbH [http://www.ibh.de/]
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

package ImVirt::VMD::OpenVZ;

use strict;
use warnings;
use constant PRODUCT => '|OpenVZ';

use ImVirt;
use ImVirt::Utils::procfs;

ImVirt::register_vmd(__PACKAGE__);

sub detect($) {
    ImVirt::debug(__PACKAGE__, 'detect()');

    my $dref = shift;

    foreach my $fn (qw(time_list bus/pci/devices bus/input/devices)) {
	if(procfs_isfile('time_list')) {
	    ImVirt::dec_pts($dref, IMV_PTS_MINOR, IMV_VIRTUAL, PRODUCT);
	}
	else {
	    ImVirt::inc_pts($dref, IMV_PTS_MINOR, IMV_VIRTUAL, PRODUCT);
	}
    }

    if(procfs_isdir('vz') && !procfs_isdir('bc')) {
	ImVirt::inc_pts($dref, IMV_PTS_MAJOR, IMV_VIRTUAL, PRODUCT);
    }
    else {
	ImVirt::dec_pts($dref, IMV_PTS_NORMAL, IMV_VIRTUAL, PRODUCT);
    }
}

sub pres() {
    return (PRODUCT);
}
1;
