output "web_server_ip" {
  description = "Static Elastic IP for Node 1 (Web Server)"
  value       = aws_eip.web_eip.public_ip
}
output "jenkins_ip" {
  description = "Static Elastic IP for Node 2 (Jenkins & SonarQube Hub)"
  value       = aws_eip.jenkins_eip.public_ip
}
output "monitor_ip" {
  description = "Static Elastic IP for Node 3 (Monitoring Node)"
  value       = aws_eip.monitor_eip.public_ip
}