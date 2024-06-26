<?php
/*
 * OpenSTAManager: il software gestionale open source per l'assistenza tecnica e la fatturazione
 * Copyright (C) DevCode s.r.l.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

include_once __DIR__.'/../../core.php';

use Models\Upload;
use Models\Module;
use Modules\Anagrafiche\Anagrafica;
use Modules\Anagrafiche\Sede;
use Modules\Contratti\Contratto;
use Modules\Interventi\Intervento;
use Modules\Scadenzario\Scadenza;
use Modules\Preventivi\Preventivo;
use Modules\Ordini\Ordine;

// Anagrafica
$anagrafica = $intervento->anagrafica;

// Sede
if ($intervento->idsede_destinazione) {
    $sede = $dbo->selectOne('an_sedi', '*', ['id' => $intervento->idsede_destinazione]);
} else {
    $sede = $anagrafica->toArray();
}

// Referente
$referente = null;
if ($intervento->idreferente) {
    $referente = $dbo->selectOne('an_referenti', '*', ['id' => $intervento->idreferente]);
}

// Contratto
$contratto = null;
$ore_erogate = 0;
$ore_previste = 0;
$perc_ore = 0;
$color = 'danger';
if ($intervento->id_contratto) {
    $contratto = Contratto::find($intervento->id_contratto);
    $ore_erogate = $contratto->interventi->sum('ore_totali');
    $ore_previste = $contratto->getRighe()->where('um', 'ore')->sum('qta');
    $perc_ore = $ore_previste != 0 ? ($ore_erogate * 100) / $ore_previste : 0;
    if ($perc_ore < 75) {
        $color = 'success';
    } elseif ($perc_ore <= 100) {
        $color = 'warning';
    }
}

// Preventivo
$preventivo = null;
if ($intervento->id_preventivo) {
    $preventivo = Preventivo::find($intervento->id_preventivo);
}

// Ordine
$ordine = null;
if ($intervento->id_ordine) {
    $ordine = Ordine::find($intervento->id_ordine);
}

// Altre attività
$interventi_programmati = Intervento::select('in_interventi.*')
    ->join('in_statiintervento', 'in_interventi.idstatointervento', '=', 'in_statiintervento.id')
    ->where('idanagrafica', $intervento->idanagrafica)
    ->where('idsede_destinazione', $intervento->idsede_destinazione)
    ->where('is_completato', '!=', 1)
    ->where('in_interventi.id', '!=', $id_record)
    ->get();

// Insoluti
$insoluti = Scadenza::where('idanagrafica', $intervento->idanagrafica)
    ->whereRaw('co_scadenziario.da_pagare > co_scadenziario.pagato')
    ->whereRaw('co_scadenziario.scadenza < NOW()')
    ->count();

// Logo
$logo = Upload::where('id_module', (new Module())->getByField('title', 'Anagrafiche'))->where('id_record', $intervento->idanagrafica)->where('name', 'Logo azienda')->first()->filename ?: App::getPaths()['img'].'/logo_header.png';

echo '
<hr>
<div class="row">
    <div class="col-md-1">
        <img src="'.base_path().'/files/anagrafiche/'.$logo.'" class="img-responsive">
    </div>';

// Cliente
echo '
    <div class="col-md-3">
        <h4 style="margin:4px 0;"><b>'.$anagrafica->ragione_sociale.'</b></h4>

        <p style="margin:3px 0;">
            '.($sede['nomesede'] ? $sede['nomesede'].'<br>' : '').'
            '.$sede['indirizzo'].'<br>
            '.$sede['cap'].' - '.$sede['citta'].' ('.$sede['provincia'].')
        </p>

        <p style="margin:3px 0;">
            '.($sede['telefono'] ? '<a class="btn btn-default btn-xs" href="tel:'.$sede['telefono'].'" target="_blank"><i class="fa fa-phone text-maroon"></i> '.$sede['telefono'].'</a>' : '').'
            '.($sede['email'] ? '<a class="btn btn-default btn-xs" href="mailto:'.$sede['email'].'"><i class="fa fa-envelope text-maroon"></i> '.$sede['email'].'</a>' : '').'
            '.($referente['nome'] ? '<p></p><i class="fa fa-user-o text-muted"></i> '.$referente['nome'].'<br>' : '').'
            '.($referente['telefono'] ? '<a class="btn btn-default btn-xs" href="tel:'.$referente['telefono'].'" target="_blank"><i class="fa fa-phone text-maroon"></i> '.$referente['telefono'].'</a>' : '').'
            '.($referente['email'] ? '<a class="btn btn-default btn-xs" href="mailto:'.$referente['email'].'"><i class="fa fa-envelope text-maroon"></i> '.$referente['email'].'</a>' : '').'
        </p>
    </div>';

// Panoramica
echo '
    <div class="col-md-4">
        <div class="box box-info">
            <div class="box-header">
                <h3 class="box-title"><i class="fa fa-map"></i> '.tr('Panoramica').'</h3>
            </div>
            <div class="box-body">

                <p style="margin:3px 0;"><i class="fa fa-'.($insoluti ? 'warning text-danger' : 'check text-success').'"></i>  
                    '.($insoluti ? tr('Sono presenti insoluti') : tr('Non sono presenti insoluti')).'
                </p>

                <p style="margin:3px 0;"><i class="fa '.(count($interventi_programmati) == 0 ? 'fa-clock-o text-success' : 'fa-clock-o text-warning').'"></i> '.(count($interventi_programmati) == 0 ? tr('Non sono presenti altre attività programmate') : 'Sono presenti altre attività programmate');
if (count($interventi_programmati) != 0) {
    foreach ($interventi_programmati as $intervento_programmato) {
        echo ' <a class="btn btn-default btn-xs" href="'.base_path().'/editor.php?id_module='.Modules::get('Interventi')['id'].'&id_record='.$intervento_programmato->id.'" target="_blank">'.$intervento_programmato->codice.'</a>';
    }
}
echo '
                </p>';
// Contratto
if ($contratto) {
    echo'
                <p style="margin:3px 0;"><i class="fa fa-book text-info"></i>
                    '.tr('Contratto collegato').':</b> <a class="btn btn-default btn-xs" href="'.base_path().'/editor.php?id_module='.(new Module())->getByField('title', 'Contratti').'&id_record='.$contratto->id.'" target="_blank">'.$contratto->numero.'</a>';
    if ($ore_previste > 0) {
        echo '
                     - '. tr('Ore erogate').':</b> '.$ore_erogate.'/'.$ore_previste.'<br>

                    <div class="progress" style="margin:0; height:8px;">
                        <div class="progress-bar progress-bar-'.$color.'" style="width:'.$perc_ore.'%"></div>
                    </div>
                </p>';
    }
}

// Preventivo
if ($preventivo) {
    echo '
                <p style="margin:3px 0;"><i class="fa fa-book text-info"></i>
                    '.tr('Preventivo collegato').':</b> <a class="btn btn-default btn-xs" href="'.base_path().'/editor.php?id_module='.(new Module())->getByField('title', 'Preventivi').'&id_record='.$preventivo->id.'" target="_blank">'.$preventivo->numero.'</a>
                </p>';
    }

// Ordine
if($ordine) {
    echo '
                <p style="margin:3px 0;"><i class="fa fa-book text-info"></i>
                    <b>'.tr('Ordine collegato').':</b> <a class="btn btn-default btn-xs" href="'.base_path().'/editor.php?id_module='.(new Module())->getByField('title', 'Ordini cliente').'&id_record='.$ordine->id.'" target="_blank">'.$ordine->numero.'</a>
                </p>';
}
echo'                
            </div>
        </div>
    </div>';

// Geolocalizzazione
$anagrafica_cliente = $intervento->anagrafica;
$sede_cliente = $anagrafica_cliente->sedeLegale;
if (!empty($intervento->idsede_destinazione)) {
    $sede_cliente = Sede::find($intervento->idsede_destinazione);
}

$anagrafica_azienda = Anagrafica::find(setting('Azienda predefinita'));
$sede_azienda = $anagrafica_azienda->sedeLegale;

echo '
    <div class="col-md-4">
        <div class="box box-info">
            <div class="box-header">
                <h3 class="box-title"><i class="fa fa-map"></i> '.tr('Geolocalizzazione').'</h3>
            </div>
            <div class="box-body">';

if (!empty($sede_cliente->gaddress) || (!empty($sede_cliente->lat) && !empty($sede_cliente->lng))) {
    echo '
                <div id="map-edit" style="width: 100%;"></div>

                <div class="clearfix"></div>
                <br>
                
                <div class="row">
                    <div class="col-md-6">';
    // Navigazione diretta verso l'indirizzo
    echo '
                        <a class="btn btn-xs btn-default btn-block" onclick="$(\'#map-edit\').height(180); caricaMappa(); $(this).hide();">
                            <i class="fa fa-compass"></i> '.tr('Carica mappa').'
                        </a>
                    </div>
                    
                    <div class="col-md-6">';
    // Navigazione diretta verso l'indirizzo
    echo '
                        <a class="btn btn-xs btn-default btn-block" onclick="calcolaPercorso()">
                            <i class="fa fa-map-signs"></i> '.tr('Calcola percorso').'
                        </a>
                    </div>
                </div>';
} else {
    echo '
                <div class="row">
                    <div class="col-md-6">';
    // Navigazione diretta verso l'indirizzo
    echo '
                        <a class="btn btn-xs btn-default btn-block" onclick="calcolaPercorso()">
                            <i class="fa fa-map-signs"></i> '.tr('Calcola percorso').'
                        </a>
                    </div>

                    <div class="col-md-6">';
    // Ricerca diretta su Mappa
    echo '
                        <a class="btn btn-xs btn-default btn-block" onclick="cercaOpenStreetMap()">
                            <i class="fa fa-map-marker"></i> '.tr('Cerca su Mappa').'
                        </a>
                    </div>
                </div>';
}

    echo '     
            </div>
        </div>
    </div>            
</div>

<script>
    function modificaPosizione() {
        openModal("'.tr('Modifica posizione').'", "'.$module->fileurl('modals/posizione.php').'?id_module='.$id_module.'&id_record='.$id_record.'");
    }

    function cercaOpenStreetMap() {
        const indirizzo = getIndirizzoAnagrafica();

        const destinazione = (!isNaN(indirizzo[0]) && !isNaN(indirizzo[1])) ? indirizzo[0] + ","+ indirizzo[1] : indirizzo[2];
        if (isMobile.any) {
            window.open("geo:" + destinazione + "?z=16&q=" + destinazione);
        } else {
            if (!isNaN(indirizzo[0]) && !isNaN(indirizzo[1])) {
                window.open("https://www.openstreetmap.org/?mlat=" + indirizzo[0] + "&mlon=" + indirizzo[1] + "#map=12/" + destinazione + "/" + indirizzo[1]);
            } else {
                window.open("https://www.openstreetmap.org/search?query=" + indirizzo[2] + "#map=12");
            }
        }
    }

    function calcolaPercorso() {
        const indirizzo_partenza = getIndirizzoAzienda();
        const indirizzo_destinazione = getIndirizzoAnagrafica();

        const destinazione = (!isNaN(indirizzo_destinazione[0]) && !isNaN(indirizzo_destinazione[1])) ? indirizzo_destinazione[0] + ","+ indirizzo_destinazione[1] : indirizzo_destinazione[2];

        if (isMobile.any) {
            window.open("geo:" + destinazione + "?z=16&q=" + destinazione);
        } else {
            window.open("https://www.openstreetmap.org/directions?engine=fossgis_osrm_car&route=" + indirizzo_partenza + ";" + destinazione);
        }
    }

    function getIndirizzoAzienda() {
        const indirizzo = "'.$sede_azienda->indirizzo.'";
        const citta = "'.$sede_azienda->citta.'";

        const lat = parseFloat("'.$sede_azienda->lat.'");
        const lng = parseFloat("'.$sede_azienda->lng.'");

        if (lat && lng){
            return lat + ","+ lng;
        } else {
            return "";
        }
    }

    function getIndirizzoAnagrafica() {
        const indirizzo = "'.$sede_cliente->indirizzo.'";
        const citta = "'.$sede_cliente->citta.'";

        const lat = parseFloat("'.$sede_cliente->lat.'");
        const lng = parseFloat("'.$sede_cliente->lng.'");

        const indirizzo_default = encodeURI(indirizzo) + "," + encodeURI(citta);

        return [lat, lng, indirizzo_default];
    }

    var map = null;
    function caricaMappa() {
        const lat = parseFloat("'.$sede_cliente->lat.'");
        const lng = parseFloat("'.$sede_cliente->lng.'");
    
        var container = L.DomUtil.get("map-edit"); 
        if(container._leaflet_id != null){ 
            map.eachLayer(function (layer) {
                if(layer instanceof L.Marker) {
                    map.removeLayer(layer);
                }
            });
        } else {
            map = L.map("map-edit", {
                gestureHandling: true
            });
    
            L.tileLayer("'.setting('Tile server OpenStreetMap').'", {
                maxZoom: 17,
                attribution: "© OpenStreetMap"
            }).addTo(map); 
        }
    
        var icon = new L.Icon({
            iconUrl: globals.rootdir + "/assets/dist/img/marker-icon.png",
            shadowUrl:globals.rootdir + "/assets/dist/img/leaflet/marker-shadow.png",
            iconSize: [25, 41],
            iconAnchor: [12, 41],
            popupAnchor: [1, -34],
            shadowSize: [41, 41]
        });

        var marker = L.marker([lat, lng], {
            icon: icon
        }).addTo(map);
    
        map.setView([lat, lng], 10);
    }
</script>';
