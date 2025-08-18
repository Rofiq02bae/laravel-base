<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Mail;

Route::get('/', function () {
    return view('welcome');
});

// Health check endpoint for monitoring
Route::get('/health', function () {
    try {
        // Check database connection
        DB::connection()->getPdo();
        
        // Check storage writability
        $storageWritable = is_writable(storage_path());
        
        // Check if key services are running
        $checks = [
            'status' => 'healthy',
            'timestamp' => now()->toISOString(),
            'services' => [
                'database' => 'healthy',
                'storage' => $storageWritable ? 'healthy' : 'unhealthy',
                'cache' => 'healthy'
            ],
            'version' => config('app.version', '1.0.0'),
            'environment' => config('app.env')
        ];
        
        return response()->json($checks, 200);
    } catch (Exception $e) {
        return response()->json([
            'status' => 'unhealthy',
            'timestamp' => now()->toISOString(),
            'error' => $e->getMessage()
        ], 503);
    }
});

// API Health check
Route::prefix('api')->group(function () {
    Route::get('/health', function () {
        return response()->json([
            'status' => 'healthy',
            'api_version' => 'v1',
            'timestamp' => now()->toISOString()
        ]);
    });
});

Route::get('/test-mail', function () {
    try {
        Mail::raw('Hello from Laravel 12! This is a test email from Mailhog.', function ($message) {
            $message->to('test@example.com')
                    ->subject('Test Email from Laravel 12');
        });
        
        return response()->json([
            'status' => 'success',
            'message' => 'Email sent successfully! Check Mailhog at http://localhost:8025'
        ]);
    } catch (Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => 'Failed to send email: ' . $e->getMessage()
        ]);
    }
});

Route::get('/test-mail-multiple', function () {
    try {
        // Test multiple recipients
        Mail::raw('This is a test email to multiple recipients from Laravel 12!', function ($message) {
            $message->to(['user1@example.com', 'user2@example.com'])
                    ->cc('cc@example.com')
                    ->bcc('bcc@example.com')
                    ->subject('Multiple Recipients Test from Laravel 12')
                    ->from('noreply@laravel.test', 'Laravel 12 App');
        });
        
        return response()->json([
            'status' => 'success',
            'message' => 'Multi-recipient email sent successfully! Check Mailhog at http://localhost:8025'
        ]);
    } catch (Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => 'Failed to send multi-recipient email: ' . $e->getMessage()
        ]);
    }
});
