#
# == Class certsigner::awsfacts
#   Configures facts.d location with an executable script to provide various ec2
#   facts
#
# === Usage
# include certsigner::awsfacts
#
class certsigner::awsfacts {
  file { "${settings::pluginfactdest}/ec2_public.sh":
    ensure  => file,
    mode    => '0755',
    owner   => $settings::user,
    group   => $settings::group,
    source => "puppet:///modules/certsigner/ec2_public.sh",
  }
}
