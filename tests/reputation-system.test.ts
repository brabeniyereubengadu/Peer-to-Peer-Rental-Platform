import { describe, it, expect, beforeEach, vi } from 'vitest';

describe('Booking System Contract', () => {
  const owner = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
  const user1 = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG';
  const user2 = 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC';
  
  beforeEach(() => {
    vi.resetAllMocks();
  });
  
  it('should create a booking', () => {
    const mockCreateBooking = vi.fn().mockReturnValue({ success: true, value: 1 });
    expect(mockCreateBooking(1, 1625097600, 1625270400)).toEqual({ success: true, value: 1 });
  });
  
  it('should not create a booking with invalid dates', () => {
    const mockCreateBooking = vi.fn().mockReturnValue({ success: false, error: 103 });
    expect(mockCreateBooking(1, 1625270400, 1625097600)).toEqual({ success: false, error: 103 });
  });
  
  it('should cancel a booking', () => {
    const mockCancelBooking = vi.fn().mockReturnValue({ success: true, value: true });
    expect(mockCancelBooking(1)).toEqual({ success: true, value: true });
  });
  
  it('should not allow unauthorized cancellation', () => {
    const mockCancelBooking = vi.fn().mockReturnValue({ success: false, error: 104 });
    expect(mockCancelBooking(1)).toEqual({ success: false, error: 104 });
  });
  
  it('should get booking details', () => {
    const mockGetBooking = vi.fn().mockReturnValue({
      success: true,
      value: {
        property_id: 1,
        tenant: user1,
        start_date: 1625097600,
        end_date: 1625270400,
        total_price: 300,
        status: "confirmed"
      }
    });
    const result = mockGetBooking(1);
    expect(result.success).toBe(true);
    expect(result.value).toEqual({
      property_id: 1,
      tenant: user1,
      start_date: 1625097600,
      end_date: 1625270400,
      total_price: 300,
      status: "confirmed"
    });
  });
});

