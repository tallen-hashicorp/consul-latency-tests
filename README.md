# consul-latency-tests
Testing consul across multiple geographic regions

## To Run
```bash
terraform init
terrafrom apply
```

```bash
ansible-playbook -i inventory.ini ansible/setup_consul.yml
ansible-playbook -i inventory.ini ansible/setup_client.yml
```