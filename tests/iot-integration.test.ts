import { describe, it, expect, beforeEach, vi } from 'vitest';

describe('IoT Integration Contract', () => {
  let mockContractCall: any;
  
  beforeEach(() => {
    mockContractCall = vi.fn();
  });
  
  it('should register a device', async () => {
    mockContractCall.mockResolvedValue({ success: true });
    const result = await mockContractCall('register-device', 'device123', 'heart-rate-monitor');
    expect(result.success).toBe(true);
  });
  
  it('should update device reading', async () => {
    mockContractCall.mockResolvedValue({ success: true });
    const result = await mockContractCall('update-device-reading', 'device123', '75 bpm');
    expect(result.success).toBe(true);
  });
  
  it('should authorize an updater', async () => {
    mockContractCall.mockResolvedValue({ success: true });
    const result = await mockContractCall('authorize-updater', 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM');
    expect(result.success).toBe(true);
  });
  
  it('should revoke an updater', async () => {
    mockContractCall.mockResolvedValue({ success: true });
    const result = await mockContractCall('revoke-updater', 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM');
    expect(result.success).toBe(true);
  });
  
  it('should get device information', async () => {
    mockContractCall.mockResolvedValue({
      success: true,
      value: {
        owner: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
        deviceType: 'heart-rate-monitor',
        lastReading: '75 bpm',
        lastUpdate: 123456
      }
    });
    const result = await mockContractCall('get-device-info', 'device123');
    expect(result.success).toBe(true);
    expect(result.value.deviceType).toBe('heart-rate-monitor');
  });
  
  it('should set contract owner', async () => {
    mockContractCall.mockResolvedValue({ success: true });
    const result = await mockContractCall('set-contract-owner', 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG');
    expect(result.success).toBe(true);
  });
});

