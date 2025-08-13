<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

class CartCalculationTest extends TestCase
{
    public function test_cart_total_calculation()
    {
        $items = [
            ['price' => 10.00, 'quantity' => 2],
            ['price' => 15.50, 'quantity' => 1],
            ['price' => 5.25, 'quantity' => 3]
        ];

        $expected = (10.00 * 2) + (15.50 * 1) + (5.25 * 3);
        $actual = $this->calculateCartTotal($items);

        $this->assertEquals($expected, $actual);
    }

    public function test_apply_discount_percentage()
    {
        $subtotal = 100.00;
        $discountPercent = 10;

        $expected = 90.00;
        $actual = $this->applyPercentageDiscount($subtotal, $discountPercent);

        $this->assertEquals($expected, $actual);
    }

    public function test_apply_discount_fixed_amount()
    {
        $subtotal = 100.00;
        $discountAmount = 15.00;

        $expected = 85.00;
        $actual = $this->applyFixedDiscount($subtotal, $discountAmount);

        $this->assertEquals($expected, $actual);
    }

    public function test_calculate_tax()
    {
        $subtotal = 100.00;
        $taxRate = 8.5; // 8.5%

        $expected = 8.50;
        $actual = $this->calculateTax($subtotal, $taxRate);

        $this->assertEquals($expected, $actual);
    }

    private function calculateCartTotal(array $items): float
    {
        return array_reduce($items, function ($total, $item) {
            return $total + ($item['price'] * $item['quantity']);
        }, 0);
    }

    private function applyPercentageDiscount(float $amount, float $percent): float
    {
        return $amount - ($amount * $percent / 100);
    }

    private function applyFixedDiscount(float $amount, float $discount): float
    {
        return max(0, $amount - $discount);
    }

    private function calculateTax(float $amount, float $rate): float
    {
        return round($amount * $rate / 100, 2);
    }
}
