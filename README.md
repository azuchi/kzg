# KZG for Ruby

A library for [KZG commitment](http://cacr.uwaterloo.ca/techreports/2010/cacr2010-10.pdf) over BLS12-381 in Ruby.

Note: This library has not been security audited and tested widely, so should not be used in production. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kzg'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install kzg

## Usage

### Setup

The first step is to generate public parameters via Trusted Setup.
The following method specifies the secret value for development purposes,
but essentially you need to create these parameters in a way that nobody knows the secret.

`KZG.setup_params` takes the secret value and the maximum degree + 1 of the polynomial to be generated as input and outputs the public parameters.
The public parameters consist of an array of point in `BLS::PointG1` and `BLS::PointG2`.

```ruby
require 'kzg'

secret = xxx # secret number
n = 10
setting = KZG.setup_params(secret, n)
```

The above public parameters can support up to a polynomial of degree 9.

### Commitment

With a public parameter, a commitment to a polynomial can be made.

`KZG::Commitment#from_coeffs` creates the corresponding polynomial commitment from the public parameters and the coefficients of the polynomial.

```ruby
coefficients = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
commitment = KZG::Commitment.from_coeffs(setting, coefficients)
commitment.value
```

`KZG::Commitment#value` returns the committed value, i.e. the point in the `BLS::PointG1`.

The committer can compute proof that the value of the polynomial (f(x)) for any value (x) is correct. 

```ruby
proof = commitment.compute_proof(35)
```

This proof is a point in the `BLS::PointG1`.

#### Multi proof

A multi-proof for disclosing multiple x values is created as follows:

```ruby
x = [1, 2, 3]

multi_proof = commitment.compute_multi_proof(x)
```

This proof is a point in the `BLS::PointG1`.

### Verify

Verifiers can use committed value and proof to verify that the value of f(x) for the value of x is correct.

```ruby
x = 35
y = 808951170278371
setting.valid_proof?(commitment.value, proof, x, y)
```

#### Multi proof

The validity of multiple proofs disclosing more than one value can be verified as follows:

```ruby
x = [1, 2, 3]
y = [55, 9217, 280483]
setting.valid_multi_proof?(commitment.value, multi_proof, x, y)
```

### Use as vector commitment

When used as a Vector commitment, the value to be committed is encoded in a polynomial expression as the evaluated value of the polynomial.
For example, if commit to the vector [3, 2, 9], compute the polynomial pass the points (1, 3), (2, 2), (3, 9). 
This can be computed by polynomial interpolation.

`KZG::Polynomial#lagrange_interpolate` method recovers a polynomial from several points using Lagrangian interpolation.
Then commitment is created using the restored polynomial.

```ruby
x = [1, 2, 3]
y = [3, 2, 9]

polynomial = KZG::Polynomial.lagrange_interpolate(x, y)

commitment = KZG::Commitment.from_coeffs(setting, polynomial.coeffs)

# compute proof
proof = commitment.compute_proof(3)
# verify
setting.valid_proof?(commitment.value, proof, 3, 9)
```
