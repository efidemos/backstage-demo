import { createBackendModule } from '@backstage/backend-plugin-api';
import {
  PolicyDecision,
  AuthorizeResult,
} from '@backstage/plugin-permission-common';
import { PermissionPolicy } from '@backstage/plugin-permission-node';
import { policyExtensionPoint } from '@backstage/plugin-permission-node/alpha';

class TestPermissionPolicy implements PermissionPolicy {
  async handle(): Promise<PolicyDecision> {
    return { result: AuthorizeResult.ALLOW };

    // switch to DENY in order to verify permissions system up and running as expected
    // return { result: AuthorizeResult.DENY };
  }
}

export default createBackendModule({
  pluginId: 'permission',
  moduleId: 'permission-policy',
  register(reg) {
    reg.registerInit({
      deps: { policy: policyExtensionPoint },
      async init({ policy }) {
        policy.setPolicy(new TestPermissionPolicy());
      },
    });
  },
});