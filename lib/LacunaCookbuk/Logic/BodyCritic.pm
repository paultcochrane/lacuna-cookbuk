use v6;

use LacunaCookbuk::Logic;
use Form;

class BodyCritic is Logic;

submethod elaborate_spaceport(Planet $planet) {
    my SpacePort $spaceport = $planet.find_space_port;

#bug?
    my Int $free = $spaceport.free_docks;    
    my Str $docks = $free == 0 ?? "FULL" !! ~$free;
    my Str $max = ~$spaceport.max_ships;
    
    
    print form( 
	'{<<<<<<<<<<<<<<<<<<<<<} {>>>>>>>>>>>>>>>>>>}/{<<<<}',
	$planet.name, $docks, $max);

}

submethod elaborate_intelligence(Planet $planet) {
    my Intelligence $imini = $planet.find_intelligence_ministry;
    my Str $numspies = ~$imini.current;
    my Str $spies = $numspies == 0 ?? "NONE!!!" !! ~$numspies;
    my Str $max = ~$imini.maximum;     
    print form( 
	'{<<<<<<<<<<<<<<<<<<<<<<<} {>>>>>>>>>>>>>>>>>>}/{<<<<}',
	$planet.name, $spies, $max);

}

submethod elaborate {
    say "Spaceport -- Docks";
    for self.bodybuilder.planets -> Planet $planet {
	self.elaborate_spaceport($planet);
    }

    say "\nIntellignece -- Spies";
    for self.bodybuilder.planets -> Planet $planet {
	self.elaborate_intelligence($planet);
    }

}