<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

class ProductValidationTest extends TestCase
{
    public function test_product_name_validation()
    {
        $validNames = ['iPhone 14', 'Samsung Galaxy', 'Product ABC-123'];
        $invalidNames = ['', '   ', 'A', str_repeat('A', 256)];

        foreach ($validNames as $name) {
            $this->assertTrue($this->isValidProductName($name));
        }

        foreach ($invalidNames as $name) {
            $this->assertFalse($this->isValidProductName($name));
        }
    }

    public function test_product_price_validation()
    {
        $validPrices = [0.01, 10.99, 1000, 999999.99];
        $invalidPrices = [-1, 0, -10.50, 'invalid'];

        foreach ($validPrices as $price) {
            $this->assertTrue($this->isValidPrice($price));
        }

        foreach ($invalidPrices as $price) {
            $this->assertFalse($this->isValidPrice($price));
        }
    }

    private function isValidProductName($name): bool
    {
        return is_string($name) && 
               strlen(trim($name)) >= 2 && 
               strlen(trim($name)) <= 255;
    }

    private function isValidPrice($price): bool
    {
        return is_numeric($price) && $price > 0;
    }
}
