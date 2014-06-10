use v6;

use LacunaCookbuk::Logic;
use Form;
use Term::ANSIColor;


class ShipCritic does Logic;

constant $limited_format= '{<<<<<<<<<<<<<<<<<<<<<<<<<<<} {>>>>}/{<<<<} {>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>}';
constant $ruler = '-' x 160;
constant $ship_templ = '{<<<<<<<<<<<<<<<<<<<<<<<<<} ' ~ ' {>>>>>>>} ' x 6;

submethod elaborate_spaceport(Planet $planet --> SpacePort) {
    
    my SpacePort $spaceport = $planet.find_space_port;

#bug?
    my Int $free = $spaceport.docks_available;    
    my Str $docks = $free == 0 ?? "FULL" !! ~$free;
    my Str $max = ~$spaceport.max_ships;
    my %shipz = $spaceport.docked_ships;
    my Str $ships = self.format_ships(%shipz);
    
    
    print form( 
	$limited_format,
	$planet.name, $docks, $max, $ships);

    return $spaceport;
}

#| If any of ship attributes is
#| <45% RED and scuttled if docked
#| <65% YELLOW
#| >100% Blue
submethod elaborate_ships {   
    my %ports; 
    {
	say BOLD,"\n\nSpaceport -- Docks";
	my @header = <planet free all details>;
	print  form ($limited_format, @header);
	say $ruler, RESET;
	for self.bodybuilder.planets -> Planet $planet {
	    %ports{$planet.name} = self.elaborate_spaceport($planet);
	}

    }
    {
	my %available = self.bodybuilder.home_planet.find_shipyard.get_buildable;
	for %ports.pairs -> $pair {
	    
	    my @shipz = $pair.value.view_all_ships;
	    say;
	    say BOLD, $pair.key;
	    say $ruler;
	    print form($ship_templ, 'Name', 'ID', 'Speed','Stealth', 'Hold size', 'Combat', 'Task'), RESET;
	    for @shipz -> @ship_h{

		for @ship_h -> %ship {
		    
		    my %compared = self.compare_ships(%ship, %available{%ship<type>}<attributes>);
		    my Str $color = 'reset';
		    $color = 'cyan' if any(%compared.values) > 100;
		    $color = 'yellow' if any(%compared.values) < 65;
		    if any(%compared.values) < 45 {
			$color = 'red';
			if %ship<can_scuttle> {
			$pair.value.scuttle_ship(%ship<id>);
			%ship<task> = "Scuttled"
			}

		    }
		    my Str $line = form($ship_templ,
					%ship<name>, ~%ship<id>,
					~(%compared<speed>),
					~(%compared<stealth>),
					~(%compared<hold_size>),
					~(%compared<combat>),
					~(%ship<task>)
			);
		    print colored($line, $color);
		    
		}

	    }
	}
    }
}

method compare_ships(%existing, %reference --> Hash){
    my %ret;
    
    %ret<speed> = calculate_percentage(%existing<speed>,%reference<speed>);
    %ret<stealth> = calculate_percentage(%existing<stealth>,%reference<stealth>);
    %ret<hold_size> = calculate_percentage(%existing<hold_size>,%reference<hold_size>);    
    %ret<combat> = calculate_percentage(%existing<combat> , %reference<combat>);

    %ret;

}

sub calculate_percentage($a, $b --> Int) {
    return 100 if $a*$b == 0;
    return Int($a*100/$b);
    
}

method format_ships(%ships --> Str) {
    my Str $ret;
    for %ships.keys -> Str $key {
	$ret ~=	 $key ~ ":" ~ %ships{$key} ~ ' ';
    }
    $ret;
}
