<?php

namespace App\Command;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class GHAMatrixCommand extends Command
{
    protected static $defaultName = 'app:gha:matrix';

    public function __construct(
        protected string $configPath,
        protected string $renderDir
    ) {
        parent::__construct();
    }

    protected function configure()
    {
        $this->addArgument('type', InputArgument::REQUIRED, 'Choose between ansible|php|node');
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $pathFile = $this->configPath . '/' . $input->getArgument('type') . '.json';

        $configs = json_decode(file_get_contents($pathFile), true, 512, \JSON_THROW_ON_ERROR);

        foreach ($configs['images'] as $image) {
            $optionsVariant = [];
            $matrix = [
                'repository' => [$image['repository']],
                'versions' => $image['versions'],
            ];

            if (isset($image['variants'])) {
                if (isset($image['options'])) {
                    foreach ($image['options'] as $option) {
                        foreach ($image['variants'] as $variant) {
                            $optionsVariant[] = $variant . '-' . $option;
                        }
                    }
                }
                $matrix['variants'] = [
                    ...$image['variants'],
                    ...$optionsVariant,
                ];
            }
            file_put_contents($this->renderDir . '/matrix.json', json_encode($matrix, \JSON_THROW_ON_ERROR));
        }

        return Command::SUCCESS;
    }
}
