# ImVirt - I'm virtualized?
#
# $Id$
#
# Authors:
#   Thomas Liske <liske@ibh.de>
#
# Copyright Holder:
#   2009 - 2010 (C) IBH IT-Service GmbH [http://www.ibh.de/]
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

package ImVirt;

use strict;
use warnings;
use Module::Find;
use List::Util qw(sum);
use Data::Dumper;

use constant {
    KV_POINTS	=> 'points',
    KV_SUBPRODS	=> 'prods',
    KV_PROB	=> 'prob',

    IMV_PHYSICAL	=> 'Physical',
    IMV_VIRTUAL		=> 'Virtual',

    IMV_PROP_DEFAULT	=> 0.9,

    IMV_PTS_MINOR	=> 1,
    IMV_PTS_NORMAL	=> 3,
    IMV_PTS_MAJOR	=> 6,
    IMV_PTS_DRASTIC	=> 12,
};

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT = qw(
    imv_detect
    imv_get
    imv_get_all
    IMV_PROP_DEFAULT
    IMV_PHYSICAL
    IMV_VIRTUAL
    IMV_PTS_MINOR
    IMV_PTS_NORMAL
    IMV_PTS_MAJOR
    IMV_PTS_DRASTIC
);

our $VERSION = '0.4.0';

my @vmds = ();
my $debug = 0;

sub register_vmd($) {
    my $vmd = shift || return;

    push(@vmds, $vmd);
}

sub imv_detect() {
    my %detected;
    $detected{ImVirt::IMV_PHYSICAL} = {KV_POINTS => IMV_PTS_MINOR};

    foreach my $vmd (@vmds) {
	eval "${vmd}::detect(\\\%detected);";
	warn "Error in ${vmd}::detect(): $@\n" if $@;
    }

    return %detected;
}

sub inc_pts($$@) {
    debug(__PACKAGE__, 'inc_pts('.join(', ',@_).')');

    my $dref = shift;
    my $prop = shift;

    _change_pts($prop, $dref, @_);
}

sub dec_pts($$@) {
    debug(__PACKAGE__, 'dec_pts('.join(', ',@_).')');

    my $dref = shift;
    my $prop = shift;

    _change_pts(-$prop, $dref, @_);
}

sub _change_pts($\%@) {
    my $prop = shift;
    my $ref = shift;
    my $key = shift;

    my $href = ${$ref}{$key};
    unless($href) {
        $href = ${$ref}{$key} = {KV_POINTS => 0, KV_SUBPRODS => {}};
    }

    if($#_ != -1) {
	&_change_pts($prop, ${$href}{KV_SUBPRODS}, @_);
    }
    else {
	${$href}{KV_POINTS} += $prop;
    }
}

sub _calc_vm($$$) {
    my $dref = shift;
    my $cref = shift;
    my $pts = shift;

    foreach my $prod (keys %{$dref}) {
	my $href = ${$dref}{$prod};

	if(keys %{${$href}{KV_SUBPRODS}}) {
	    &_calc_vm(${$href}{KV_SUBPRODS}, $cref, $pts + ${$href}{KV_POINTS});
	}
	else {
	    ${$cref}{$prod} = $pts + ${$href}{KV_POINTS};
	}
    }
}

sub imv_get_all(%) {
    my (%detected) = @_;
    my %calc;

    _calc_vm(\%detected, \%calc, 0);

    my $psum = sum grep { $_ > 0 } values %calc;

    foreach my $prod (keys %calc) {
	my $pts = $calc{$prod};

	$calc{$prod} = {};
	if((${calc{$prod}}{KV_POINTS} = $pts) > 0) {
	    ${calc{$prod}}{KV_PROB} = $calc{$prod}/$psum;
	}
	else {
	    ${calc{$prod}}{KV_PROB} = 0;
	}
    }

    return %calc;
}

sub imv_get($%) {
    my $prob = shift;

    my %calc = imv_get_all(@_);
    my @calc = sort { ${$calc{$b}}{KV_POINTS} > ${$calc{$a}}{KV_POINTS} } keys %calc;
    my $vm = shift @calc;

    return $vm if(${$calc{$vm}}{KV_PROB} >= $prob);

    return 'Unknown';
}

sub set_debug($) {
    $debug = shift;
}

sub debug($$) {
    printf STDERR "%24s: %s\n", @_ if($debug);
}

# autoload VMD modules
foreach my $module (findsubmod ImVirt::VMD) {
    eval "use $module;";
    die "Error loading $module: $@\n" if $@;
}

1;
