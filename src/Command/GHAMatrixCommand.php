<?php

namespace App\Command;

use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(name: 'app:gha:matrix')]
class GHAMatrixCommand extends Command
{
    public function __construct(
        protected string $configPath,
        protected string $renderDir
    ) {
        parent::__construct();
    }

    protected function configure()
    {
        $this->addArgument('type', InputArgument::REQUIRED, 'Choose between ansible|bdes|php|node|of');
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $type = $input->getArgument('type');
        $pathFile = $this->configPath . '/' . $type . '.json';

        $configs = json_decode(file_get_contents($pathFile), true, 512, \JSON_THROW_ON_ERROR);

        $renderDir = $this->renderDir . '/';

        foreach ($configs['images'] as $image) {
            $defaultData = [
                'image' => $image['repository'],
            ];

            $matrix = [];

            foreach ($image['versions'] as $version) {
                $data = $defaultData;
                $data['version'] = $version;

                if (!isset($image['variants'])) {
                    $data['dockerfile'] = $renderDir . implode('-', [$type, $version, '.Dockerfile']);
                    $data['prefix'] = implode('-', [$version]) . '-';
                    $matrix[] = $data;
                    continue;
                }

                foreach ($image['variants'] as $variant) {
                    $data['variant'] = $variant;
                    $data['dockerfile'] = $renderDir . implode('-', [$type, $version, $variant, '.Dockerfile']);
                    $data['prefix'] = implode('-', [$version, $variant]) . '-';
                    $matrix[] = $data;

                    if (isset($image['options'])) {
                        foreach ($image['options'] as $option) {
                            $data['option'] = $option;
                            $data['dockerfile'] = $renderDir . implode('-', [$type, $version, $variant, $option, '.Dockerfile']);
                            $data['prefix'] = implode('-', [$version, $variant, $option]) . '-';
                            $matrix[] = $data;
                        }
                    }
                }
            }

            /*$optionsVariant = [];
            $matrix = [
                'image' => [$image['repository']],
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
            }*/
            file_put_contents($this->renderDir . '/matrix.json', json_encode(['include' => $matrix], \JSON_THROW_ON_ERROR));
        }

        return Command::SUCCESS;
    }

    protected function getDockerFilename(string $type, string $version, string $variant = null, string $option = null): string
    {
        $filename = $type . '-' . $version;

        if ($variant) {
            $filename .= '-' . $variant;
        }

        if ($option) {
            $filename .= '-' . $option;
        }
        return $filename . '.Dockerfile';
    }
}
