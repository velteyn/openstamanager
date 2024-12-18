-- Aggiunta Marchio articolo
ALTER TABLE `mg_articoli` ADD `id_marchio` INT NULL DEFAULT NULL;

CREATE TABLE `mg_marchi` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `name` varchar(255) NOT NULL,
    `link` varchar(255) NOT NULL,
    `deleted_at` timestamp NULL DEFAULT NULL,
PRIMARY KEY (`id`)) ENGINE = InnoDB; 

INSERT INTO `zz_modules` (`name`, `directory`, `options`, `options2`, `icon`, `version`, `compatibility`, `order`, `parent`, `default`, `enabled`, `use_notes`, `use_checklists`) VALUES ('Marchi', 'marchi', 'SELECT |select| FROM `mg_marchi` WHERE 1=1 HAVING 2=2 ORDER BY `mg_marchi`.`name`', '', 'fa fa-angle-right', '2.6', '2.6', '7', (SELECT `id` FROM `zz_modules` AS `t` WHERE `name` = 'Tabelle'), '1', '1', '1', '1');

SELECT @id_module := `id` FROM `zz_modules` WHERE `name` = 'Marchi';
INSERT INTO `zz_modules_lang` (`id_lang`, `id_record`, `title`) VALUES 
('1', @id_module, 'Marchi'),
('2', @id_module, 'Marchi');

SELECT @id_module := `id` FROM `zz_modules` WHERE `name` = 'Marchi';
INSERT INTO `zz_views` (`id_module`, `name`, `query`, `order`, `search`, `slow`, `format`, `html_format`, `search_inside`, `order_by`, `visible`, `summable`, `default`) VALUES 
(@id_module, 'id', 'mg_marchi.id', '0', '0', '0', '0', '0', '', '', '0', '0', '0'),
(@id_module, 'Nome', 'mg_marchi.name', '1', '0', '0', '0', '0', '', '', '1', '0', '0'),
(@id_module, 'Link', 'mg_marchi.link', '2', '0', '0', '0', '0', '', '', '1', '0', '0');

SELECT @id_module := `id` FROM `zz_modules` WHERE `name` = 'Marchi';
INSERT INTO `zz_views_lang` (`id_lang`, `id_record`, `title`) VALUES
(1, (SELECT `id` FROM `zz_views` WHERE `name` = 'id' AND `id_module` = @id_module), 'id'),
(2, (SELECT `id` FROM `zz_views` WHERE `name` = 'id' AND `id_module` = @id_module), 'id'),
(1, (SELECT `id` FROM `zz_views` WHERE `name` = 'Nome' AND `id_module` = @id_module), 'Nome'),
(2, (SELECT `id` FROM `zz_views` WHERE `name` = 'Nome' AND `id_module` = @id_module), 'Name'),
(1, (SELECT `id` FROM `zz_views` WHERE `name` = 'Link' AND `id_module` = @id_module), 'Link'),
(2, (SELECT `id` FROM `zz_views` WHERE `name` = 'Link' AND `id_module` = @id_module), 'Link');

-- Aggiunta modulo Stati dei DDT
ALTER TABLE `dt_statiddt` ADD `deleted_at` timestamp NULL DEFAULT NULL;

INSERT INTO `zz_modules` (`name`, `directory`, `options`, `options2`, `icon`, `version`, `compatibility`, `order`, `parent`, `default`, `enabled`, `use_notes`, `use_checklists`) VALUES ('Stati DDT', 'stati_ddt', 'SELECT |select| FROM `dt_statiddt` LEFT JOIN `dt_statiddt_lang` ON (`dt_statiddt`.`id` = `dt_statiddt_lang`.`id_record` AND `dt_statiddt_lang`.|lang|) WHERE 1=1 AND `deleted_at` IS NULL HAVING 2=2', '', 'fa fa-circle-o', '2.6', '2.6', '7', (SELECT `id` FROM `zz_modules` AS `t` WHERE `name` = 'Tabelle'), '1', '1', '1', '1');

SELECT @id_module := `id` FROM `zz_modules` WHERE `name` = 'Stati DDT';
INSERT INTO `zz_modules_lang` (`id_lang`, `id_record`, `title`) VALUES 
('1', @id_module, 'Stati dei DDT'),
('2', @id_module, 'Stati dei DDT');

SELECT @id_module := `id` FROM `zz_modules` WHERE `name` = 'Stati DDT';
INSERT INTO `zz_views` (`id_module`, `name`, `query`, `order`, `search`, `slow`, `format`, `html_format`, `search_inside`, `order_by`, `visible`, `summable`, `avg`, `default`) VALUES 
(@id_module, 'Fatturabile', 'IF(is_fatturabile, \'S&igrave;\', \'No\')', '6', '1', '0', '0', '0', NULL, NULL, '1', '0', '0', '0'), 
(@id_module, 'Completato', 'IF(completato, \'S&igrave;\', \'No\')', '5', '1', '0', '0', '0', NULL, NULL, '1', '0', '0', '0'), 
(@id_module, 'Icona', 'icona', '3', '1', '0', '0', '0', NULL, NULL, '1', '0', '0', '0'), 
(@id_module, 'Descrizione', '`dt_statiddt_lang`.`title`', '2', '1', '0', '0', '0', NULL, NULL, '1', '0', '0', '0'), 
(@id_module, 'id', '`dt_statiddt`.`id`', '1', '0', '0', '0', '0', NULL, NULL, '0', '0', '0', '1'), 
(@id_module, 'color_Colore', 'colore', '7', '0', '0', '1', '0', '', '', '1', '0', '0', '0'); 

SELECT @id_module := `id` FROM `zz_modules` WHERE `name` = 'Stati DDT';
INSERT INTO `zz_views_lang` (`id_lang`, `id_record`, `title`) VALUES 
('1', (SELECT `id` FROM `zz_views` WHERE `name` = 'Fatturabile' AND `id_module` = @id_module), 'Fatturabile'),
('2', (SELECT `id` FROM `zz_views` WHERE `name` = 'Fatturabile' AND `id_module` = @id_module), 'To be billed'), 
('1', (SELECT `id` FROM `zz_views` WHERE `name` = 'Completato' AND `id_module` = @id_module), 'Completato'), 
('2', (SELECT `id` FROM `zz_views` WHERE `name` = 'Completato' AND `id_module` = @id_module), 'Completed'), 
('1', (SELECT `id` FROM `zz_views` WHERE `name` = 'Icona' AND `id_module` = @id_module), 'Icona'), 
('2', (SELECT `id` FROM `zz_views` WHERE `name` = 'Icona' AND `id_module` = @id_module), 'Icon'), 
('1', (SELECT `id` FROM `zz_views` WHERE `name` = 'Descrizione' AND `id_module` = @id_module), 'Descrizione'), 
('2', (SELECT `id` FROM `zz_views` WHERE `name` = 'Descrizione' AND `id_module` = @id_module), 'Description'), 
('1', (SELECT `id` FROM `zz_views` WHERE `name` = 'id' AND `id_module` = @id_module), 'id'), 
('2', (SELECT `id` FROM `zz_views` WHERE `name` = 'id' AND `id_module` = @id_module), 'id'), 
('1', (SELECT `id` FROM `zz_views` WHERE `name` = 'color_Colore' AND `id_module` = @id_module), 'color_Colore'), 
('2', (SELECT `id` FROM `zz_views` WHERE `name` = 'color_Colore' AND `id_module` = @id_module), 'color_Color');

CREATE TABLE IF NOT EXISTS `co_mandati_sepa` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_banca` int(11) NOT NULL,
  `id_mandato` varchar(255) NOT NULL,
  `data_firma_mandato` DATE NOT NULL,
  `singola_disposizione` TINYINT(1) NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`id_banca`) REFERENCES `co_banche`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Aggiunta del plugin
SELECT @id_module := `id` FROM `zz_modules` WHERE `name` = 'Banche';
INSERT INTO `zz_plugins` (`name`, `idmodule_from`, `idmodule_to`, `position`, `script`, `enabled`, `default`, `order`, `compatibility`, `version`, `options2`, `options`, `directory`, `help`) VALUES
('Mandati SEPA', @id_module, @id_module, 'tab', '', 1, 1, 0, '2.6.*', '', NULL, 'custom', 'mandati_sepa', '');

INSERT INTO `zz_plugins_lang` (`id_lang`, `id_record`, `title`)
VALUES
  (1, LAST_INSERT_ID(), 'Mandati SEPA'),
  (2, LAST_INSERT_ID(), 'Mandati SEPA');

-- Allineamento campi telefono e email in viste
UPDATE `zz_views` SET `name` = 'tel_Telefono' WHERE `zz_views`.`name` = 'Telefono'; 
UPDATE `zz_views` SET `name` = 'tel_Cellulare' WHERE `zz_views`.`name` = 'Cellulare'; 
UPDATE `zz_views` SET `name` = 'emailto_Email' WHERE `zz_views`.`name` = 'Email'; 
UPDATE `zz_views_lang` SET `title` = 'tel_Telefono' WHERE `zz_views_lang`.`id_record` = (SELECT `id` FROM `zz_views` WHERE `name` = 'tel_Telefono'); 
UPDATE `zz_views_lang` SET `title` = 'tel_Cellulare' WHERE `zz_views_lang`.`id_record` = (SELECT `id` FROM `zz_views` WHERE `name` = 'tel_Cellulare');
UPDATE `zz_views_lang` SET `title` = 'emailto_Email' WHERE `zz_views_lang`.`id_record` = (SELECT `id` FROM `zz_views` WHERE `name` = 'emailto_Email');

-- Aggiunta campo modello
ALTER TABLE `mg_articoli` ADD `modello` VARCHAR(255) NULL AFTER `id_marchio`; 

INSERT INTO `zz_api_resources` (`id`, `version`, `type`, `resource`, `class`, `enabled`) VALUES
(NULL,	'v1',	'retrieve',	'pagamenti',	'Modules\\Pagamenti\\API\\v1\\Pagamenti',	1);

-- Aggiunto spedizione porto e vettore in ordini
ALTER TABLE `or_ordini` ADD `idspedizione` TINYINT NULL AFTER `codice_commessa`, ADD `idporto` TINYINT NULL AFTER `idspedizione`, ADD `idvettore` INT NULL AFTER `idporto`;

-- Aggiunta del plugin Importazione FE
SELECT @id_module := `id` FROM `zz_modules` WHERE `name` = 'Fatture di vendita';
INSERT INTO `zz_plugins` (`name`, `idmodule_from`, `idmodule_to`, `position`, `script`, `enabled`, `default`, `order`, `compatibility`, `version`, `options2`, `options`, `directory`, `help`) VALUES
('Importazione FE', @id_module, @id_module, 'tab_main', '', 1, 1, 0, '2.6.*', '2.0', NULL, 'custom', 'importFE_ZIP', '');

INSERT INTO `zz_plugins_lang` (`id_lang`, `id_record`, `title`)
VALUES
  (1, LAST_INSERT_ID(), 'Importazione FE'),
  (2, LAST_INSERT_ID(), 'Importazione FE');

-- Aggiunta impostazione per metodo di importazione XML fatture
INSERT INTO `zz_settings` (`nome`, `valore`, `tipo`, `editable`, `sezione`, `order`) VALUES ('Metodo di importazione XML fatture di vendita', 'Automatico', 'list[Automatico,Manuale]', '1', 'Fatturazione', NULL);
INSERT INTO `zz_settings_lang` (`id_record`, `id_lang`, `title`) VALUES
  (LAST_INSERT_ID(), 1, 'Metodo di importazione XML fatture di vendita'),
  (LAST_INSERT_ID(), 2, 'Metodo di importazione XML fatture di vendita');
