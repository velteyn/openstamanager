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

use Modules\Ordini\Ordine;

include_once __DIR__.'/../../core.php';

if (!empty($id_record)) {
    $ordine = Ordine::find($id_record);

    $record = $dbo->fetchOne('SELECT 
            `or_ordini`.*,
            `or_ordini`.`note`,
            `or_ordini`.`idpagamento`,
            `or_ordini`.`id` AS idordine,
            `or_ordini`.`idagente` AS idagente,
            `or_ordini`.`idstatoordine` AS idstatoordine,
            `or_statiordine_lang`.`title` AS stato,
            `or_tipiordine_lang`.`title` AS descrizione_tipodoc,
            `an_anagrafiche`.`tipo` AS tipo_anagrafica,
            `or_statiordine`.`completato` AS flag_completato
        FROM 
            `or_ordini` 
            LEFT JOIN `or_statiordine` ON `or_ordini`.`idstatoordine`=`or_statiordine`.`id`
            LEFT JOIN `or_statiordine_lang` ON (`or_statiordine_lang`.`id_record`=`or_statiordine`.`id` AND `or_statiordine_lang`.`id_lang`='.prepare(Models\Locale::getDefault()->id).')
            INNER JOIN `an_anagrafiche` ON `or_ordini`.`idanagrafica`=`an_anagrafiche`.`idanagrafica`
            INNER JOIN `or_tipiordine` ON `or_ordini`.`idtipoordine`=`or_tipiordine`.`id`
            LEFT JOIN `or_tipiordine_lang` ON (`or_tipiordine_lang`.`id_record`=`or_tipiordine`.`id` AND `or_tipiordine_lang`.`id_lang`='.prepare(Models\Locale::getDefault()->id).')
        WHERE 
            `or_ordini`.`id`='.prepare($id_record));
}
