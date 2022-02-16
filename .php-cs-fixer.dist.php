<?php

$config = new EditionsTissot\CS\Config\Config;
$config->getFinder()
    ->in(
        [
            __DIR__ . '/src',
        ]
    )
;

return $config;
