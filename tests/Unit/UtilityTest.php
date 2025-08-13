<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

class UtilityTest extends TestCase
{
    public function test_generate_order_number()
    {
        $orderNumber1 = $this->generateOrderNumber();
        $orderNumber2 = $this->generateOrderNumber();

        $this->assertNotEquals($orderNumber1, $orderNumber2);
        $this->assertMatchesRegularExpression('/^ORD-\d{8}-[A-Z0-9]{6}$/', $orderNumber1);
    }

    public function test_format_currency()
    {
        $this->assertEquals('$10.00', $this->formatCurrency(10, 'USD'));
        $this->assertEquals('€15.50', $this->formatCurrency(15.50, 'EUR'));
        $this->assertEquals('$0.99', $this->formatCurrency(0.99, 'USD'));
    }

    public function test_calculate_shipping_cost()
    {
        $this->assertEquals(5.00, $this->calculateShipping(10.00)); // Under $50
        $this->assertEquals(0.00, $this->calculateShipping(75.00)); // Over $50
        $this->assertEquals(0.00, $this->calculateShipping(50.00)); // Exactly $50
    }

    public function test_validate_email_format()
    {
        $validEmails = ['test@example.com', 'user+tag@domain.co.uk'];
        $invalidEmails = ['invalid.email', 'test@', '@domain.com'];

        foreach ($validEmails as $email) {
            $this->assertTrue($this->isValidEmail($email));
        }

        foreach ($invalidEmails as $email) {
            $this->assertFalse($this->isValidEmail($email));
        }
    }

    private function generateOrderNumber(): string
    {
        return 'ORD-' . date('Ymd') . '-' . strtoupper(substr(md5(uniqid()), 0, 6));
    }

    private function formatCurrency(float $amount, string $currency = 'USD'): string
    {
        $symbols = ['USD' => '$', 'EUR' => '€', 'GBP' => '£'];
        $symbol = $symbols[$currency] ?? '$';
        return $symbol . number_format($amount, 2);
    }

    private function calculateShipping(float $orderTotal): float
    {
        return $orderTotal >= 50 ? 0.00 : 5.00;
    }

    private function isValidEmail(string $email): bool
    {
        return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
    }
}
