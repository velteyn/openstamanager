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

namespace Modules\Emails;

use Carbon\Carbon;
use Common\SimpleModelTrait;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Notifications\EmailNotification;
use Traits\LocalPoolTrait;

class Account extends Model
{
    use SimpleModelTrait;
    use LocalPoolTrait;
    use SoftDeletes;

    protected $table = 'em_accounts';

    protected $casts = [
        'oauth2_config' => 'array',
    ];

    /** @var OAuth2 */
    protected $gestoreOAuth2;

    public function testConnection()
    {
        // Impostazione di connected_at a NULL
        $this->connected_at = null;
        $this->save();

        // Creazione email di test
        $mail = new EmailNotification($this->id);
        // Tentativo di connessione
        $result = $mail->testSMTP();

        // Salvataggio della data di connessione per test riuscito
        if ($result) {
            $this->connected_at = Carbon::now();
            $this->save();
        }

        return $result;
    }

    public function getGestoreOAuth2()
    {
        if (isset($this->gestoreOAuth2)) {
            return $this->gestoreOAuth2;
        }

        $this->gestoreOAuth2 = new OAuth2($this);

        return $this->gestoreOAuth2;
    }

    /* Relazioni Eloquent */

    public function templates()
    {
        return $this->hasMany(Template::class, 'id_account');
    }

    public function emails()
    {
        return $this->hasMany(Mail::class, 'id_account');
    }
}
