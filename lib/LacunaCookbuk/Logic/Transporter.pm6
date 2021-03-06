use v6;

use LacunaCookbuk::Model::Body::Planet;
use LacunaCookbuk::Logic::BodyBuilder;
use LacunaCookbuk::Model::Empire;
use LacunaCookbuk::Model::Structure::Trade;


class LacunaCookbuk::Logic::Transporter;

my role Cargo{
    method gather(Trade $Trade --> List) { ... }   
}

my class Glyphs does Cargo {
    

    method gather(Trade $trade --> List){
	$trade.get_glyphs;
    }

}

my class Plans does Cargo {
    
    method gather(Trade $trade --> List){
	$trade.get_plans;
    }
}

submethod transport(@goods,Planet $src, Planet $dst = home_planet)
{
    my @cargo;
    my $trade = $src.find_trade_ministry;
    return unless $trade;
    unless $trade.repaired {
        say "Cannot use TradeMinistry on " ~ $src.name;
        return;

    }
    for @goods -> $load {
	@cargo.push($load.gather($trade))
    }
    my $ship = $trade.find_fastest_ship;
    unless $ship {
        say "No ship available on {$src.name}";
        return;
    }

    my @packed = self.cut_size(@cargo, +$ship<hold_size>);
    say $trade.push(@packed) if @packed;   
}

submethod transport_all_cargo(Planet $dst = home_planet) {
    my @goods = (Glyphs, Plans);
    my @planets = planets;
    for @planets -> Planet $planet {
	#say $planet.name;	
	next if $planet.is_home;
	self.transport(@goods, $planet, $dst);
    }

}


method cut_size(@cargo, Int $limit --> Array){
    my Int $space = 0;
    
    my @neCargo;
    for @cargo -> $load {
	my $size = self.container_size($load<type>);
	$space += $size * $load<quantity>;
	
	return @neCargo if $space >= $limit;
	@neCargo.push($load);
    }
    return @neCargo;

}

my %csizes = %("glyph" => 100, "plan" => 10000);
submethod container_size(Str $type --> Int){
    %csizes{$type};
}


