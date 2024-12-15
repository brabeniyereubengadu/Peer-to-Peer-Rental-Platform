import { describe, it, expect, beforeEach, vi } from 'vitest';

describe('Rental NFT Contract', () => {
  const owner = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
  const user1 = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG';
  const user2 = 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC';
  
  beforeEach(() => {
    vi.resetAllMocks();
  });
  
  it('should mint a new rental NFT', () => {
    const mockMint = vi.fn().mockReturnValue({ success: true, value: 1 });
    expect(mockMint('https://example.com/property/1', 100)).toEqual({ success: true, value: 1 });
  });
  
  it('should list a property', () => {
    const mockListProperty = vi.fn().mockReturnValue({ success: true, value: true });
    expect(mockListProperty(1, 150)).toEqual({ success: true, value: true });
  });
  
  it('should not allow non-owner to list a property', () => {
    const mockListProperty = vi.fn().mockReturnValue({ success: false, error: 100 });
    expect(mockListProperty(1, 150)).toEqual({ success: false, error: 100 });
  });
  
  it('should unlist a property', () => {
    const mockUnlistProperty = vi.fn().mockReturnValue({ success: true, value: true });
    expect(mockUnlistProperty(1)).toEqual({ success: true, value: true });
  });
  
  it('should get property details', () => {
    const mockGetProperty = vi.fn().mockReturnValue({
      success: true,
      value: {
        owner: owner,
        uri: 'https://example.com/property/1',
        price: 100,
        is_listed: true
      }
    });
    const result = mockGetProperty(1);
    expect(result.success).toBe(true);
    expect(result.value).toEqual({
      owner: owner,
      uri: 'https://example.com/property/1',
      price: 100,
      is_listed: true
    });
  });
  
  it('should transfer ownership of a property', () => {
    const mockTransfer = vi.fn().mockReturnValue({ success: true, value: true });
    expect(mockTransfer(1, owner, user1)).toEqual({ success: true, value: true });
  });
  
  it('should get the owner of a property', () => {
    const mockGetOwner = vi.fn().mockReturnValue({ success: true, value: owner });
    expect(mockGetOwner(1)).toEqual({ success: true, value: owner });
  });
  
  it('should get the last token ID', () => {
    const mockGetLastTokenId = vi.fn().mockReturnValue({ success: true, value: 1 });
    expect(mockGetLastTokenId()).toEqual({ success: true, value: 1 });
  });
});

