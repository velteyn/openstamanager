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
use Modules\Anagrafiche\Relazione;

include_once __DIR__.'/../../core.php';

if (!empty($id_record)) {
    $record = $dbo->fetchOne('SELECT * FROM `an_relazioni` LEFT JOIN `an_relazioni_lang` ON (`an_relazioni`.`id`=`an_relazioni_lang`.`id_record` AND `an_relazioni_lang`.`id_lang`='.prepare(Models\Locale::getDefault()->id).') WHERE `an_relazioni`.`id`='.prepare($id_record));

    $relazione = Relazione::find($id_record);
}
