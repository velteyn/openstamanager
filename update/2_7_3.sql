-- Allineamento vista Contratti, correzione campo Residuo contratto
UPDATE `zz_modules` SET `options` = "
SELECT
    |select|
FROM
    `co_contratti`
    LEFT JOIN `an_anagrafiche` ON `co_contratti`.`idanagrafica` = `an_anagrafiche`.`idanagrafica`
    LEFT JOIN `an_anagrafiche` AS `agente` ON `co_contratti`.`idagente` = `agente`.`idanagrafica`
    LEFT JOIN `co_staticontratti` ON `co_contratti`.`idstato` = `co_staticontratti`.`id`
    LEFT JOIN `co_staticontratti_lang` ON (`co_staticontratti`.`id` = `co_staticontratti_lang`.`id_record` AND |lang|)
    LEFT JOIN (SELECT `idcontratto`, SUM(`subtotale` - `sconto`) AS `totale_imponibile`, SUM(`subtotale` - `sconto` + `iva`) AS `totale` FROM `co_righe_contratti` GROUP BY `idcontratto`) AS righe ON `co_contratti`.`id` = `righe`.`idcontratto`
    LEFT JOIN (WITH RigheAgg AS (SELECT idintervento,SUM(prezzo_unitario * qta) AS sommacosti_per_intervento FROM in_righe_interventi GROUP BY idintervento), TecniciAgg AS (SELECT idintervento, SUM(prezzo_ore_consuntivo) AS sommasessioni_per_intervento FROM in_interventi_tecnici GROUP BY idintervento) SELECT SUM(COALESCE(RigheAgg.sommacosti_per_intervento, 0)) AS sommacosti, SUM(COALESCE(TecniciAgg.sommasessioni_per_intervento, 0)) AS sommasessioni, i.id_contratto FROM in_interventi i LEFT JOIN RigheAgg ON RigheAgg.idintervento = i.id LEFT JOIN TecniciAgg ON TecniciAgg.idintervento = i.id GROUP BY i.id_contratto) AS spesacontratto ON spesacontratto.id_contratto = co_contratti.id
    LEFT JOIN (SELECT GROUP_CONCAT(CONCAT(matricola, IF(nome != '', CONCAT(' - ', nome), '')) SEPARATOR '<br />') AS descrizione, my_impianti_contratti.idcontratto FROM my_impianti INNER JOIN my_impianti_contratti ON my_impianti.id = my_impianti_contratti.idimpianto GROUP BY my_impianti_contratti.idcontratto) AS impianti ON impianti.idcontratto = co_contratti.id
    LEFT JOIN (SELECT um, SUM(qta) AS somma, idcontratto FROM co_righe_contratti GROUP BY um, idcontratto) AS orecontratti ON orecontratti.um = 'ore' AND orecontratti.idcontratto = co_contratti.id
    LEFT JOIN (SELECT in_interventi.id_contratto, SUM(ore) AS sommatecnici FROM in_interventi_tecnici INNER JOIN in_interventi ON in_interventi_tecnici.idintervento = in_interventi.id LEFT JOIN in_tipiintervento ON in_interventi_tecnici.idtipointervento=in_tipiintervento.id WHERE non_conteggiare=0 GROUP BY in_interventi.id_contratto) AS tecnici ON tecnici.id_contratto = co_contratti.id
    LEFT JOIN `co_categorie_contratti` ON `co_contratti`.`id_categoria` = `co_categorie_contratti`.`id`
    LEFT JOIN `co_categorie_contratti_lang` ON (`co_categorie_contratti`.`id` = `co_categorie_contratti_lang`.`id_record` AND `co_categorie_contratti_lang`.|lang|)
    LEFT JOIN `co_categorie_contratti` AS sottocategorie ON `co_contratti`.`id_sottocategoria` = `sottocategorie`.`id`
    LEFT JOIN `co_categorie_contratti_lang` AS sottocategorie_lang ON (`sottocategorie`.`id` = `sottocategorie_lang`.`id_record` AND `sottocategorie_lang`.|lang|)
WHERE
    1=1 |segment(`co_contratti`.`id_segment`)| |date_period(custom,'|period_start|' >= `data_bozza` AND '|period_start|' <= `data_conclusione`,'|period_end|' >= `data_bozza` AND '|period_end|' <= `data_conclusione`,`data_bozza` >= '|period_start|' AND `data_bozza` <= '|period_end|',`data_conclusione` >= '|period_start|' AND `data_conclusione` <= '|period_end|',`data_bozza` >= '|period_start|' AND `data_conclusione` = NULL)|
HAVING 
    2=2" WHERE `name` = 'Contratti';

UPDATE `zz_views` LEFT JOIN `zz_modules` ON `zz_views`.`id_module` = `zz_modules`.`id` SET `query` = "IF((righe.totale_imponibile - (COALESCE(sommacosti, 0) + COALESCE(sommasessioni, 0))) != 0, (righe.totale_imponibile - (COALESCE(sommacosti, 0) + COALESCE(sommasessioni, 0))), '')" WHERE `zz_views`.`name` = 'Residuo contratto' AND `zz_modules`.`name` = 'Contratti';

-- Aggiunta impostazione per OpenRouter API Key
INSERT INTO `zz_settings` (`id`, `nome`, `valore`, `tipo`, `editable`, `sezione`, `order`) VALUES 
(NULL, 'OpenRouter API Key', '', 'string', 1, 'API', NULL);

INSERT INTO `zz_settings_lang` (`id_lang`, `id_record`, `title`, `help`) VALUES 
(1, (SELECT `id` FROM `zz_settings` WHERE `nome` = 'OpenRouter API Key'),
'OpenRouter API Key',
'API Key per l''integrazione con OpenRouter AI. Ottieni la tua chiave da https://openrouter.ai/keys');

INSERT INTO `zz_settings_lang` (`id_lang`, `id_record`, `title`, `help`) VALUES 
(2, (SELECT `id` FROM `zz_settings` WHERE `nome` = 'OpenRouter API Key'),
'OpenRouter API Key',
'API Key for OpenRouter AI integration. Get your key from https://openrouter.ai/keys');

-- Aggiunta impostazione per Modello AI predefinito OpenRouter
-- Define the list of free models
SET @free_models = 'mistralai/mistral-7b-instruct,google/gemini-pro-1.5,anthropic/claude-3-haiku-20240307,openai/gpt-3.5-turbo'; -- Add/remove models as needed

INSERT INTO `zz_settings` (`id`, `nome`, `valore`, `tipo`, `editable`, `sezione`, `order`) VALUES
(NULL, 'Modello AI predefinito per OpenRouter', 'openai/gpt-3.5-turbo', CONCAT('list[', @free_models, ']'), 1, 'API', NULL);

INSERT INTO `zz_settings_lang` (`id_lang`, `id_record`, `title`, `help`) VALUES
(1, (SELECT `id` FROM `zz_settings` WHERE `nome` = 'Modello AI predefinito per OpenRouter'),
'Modello AI predefinito (OpenRouter)',
'Modello gratuito da utilizzare per impostazione predefinita con l''assistente AI di OpenRouter. Seleziona uno dei modelli disponibili.');

INSERT INTO `zz_settings_lang` (`id_lang`, `id_record`, `title`, `help`) VALUES
(2, (SELECT `id` FROM `zz_settings` WHERE `nome` = 'Modello AI predefinito per OpenRouter'),
'Default AI Model (OpenRouter)',
'Free model to use by default with the OpenRouter AI assistant. Select one of the available models.');

-- Aggiunta impostazione per il Prompt di sistema Modello AI
INSERT INTO `zz_settings` (`id`, `nome`, `valore`, `tipo`, `editable`, `sezione`, `order`) VALUES
(NULL, 'Prompt di sistema per Modello AI', 'Sei un assistente esperto che aiuta a migliorare e modificare testi.', 'textarea', 1, 'API', NULL);

INSERT INTO `zz_settings_lang` (`id_lang`, `id_record`, `title`, `help`) VALUES
(1, (SELECT `id` FROM `zz_settings` WHERE `nome` = 'Prompt di sistema per Modello AI'),
'Prompt di sistema per Modello AI',
'Il messaggio di sistema inviato all''AI per definire il suo ruolo e comportamento. Modificalo per personalizzare le risposte.');

INSERT INTO `zz_settings_lang` (`id_lang`, `id_record`, `title`, `help`) VALUES
(2, (SELECT `id` FROM `zz_settings` WHERE `nome` = 'Prompt di sistema per Modello AI'),
'System Prompt for AI Model',
'The system message sent to the AI to define its role and behavior. Modify it to customize responses.');